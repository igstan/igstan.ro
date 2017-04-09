---
title: A Safe Type-Indexed Set for Standard ML
author: Ionuț G. Stan
date: April 08, 2017
date: 2017-04-08 05:00:00 +02:00
---

I recently discovered, while preparing the slides for my [Modularity à la ML][0] talk, a solution to a problem I've come across a while ago while implementing a type-indexed set data structure in Standard ML.

## Functor-Based Data Structures

First of all, let's see how sets are represented in the [SML/NJ library][1], which is what I've used initially. The SML/NJ library provides a collection of common data structures and algorithms that aren't part of the standard Basis library mandated by Standard ML. For set data structures, it exposes an [`ORD_SET`][2] signature that's meant for sets implemented using a predefined ordering on the contained elements (there is support for hash sets, too). Two functors produce structures that satisfy the `ORD_SET` signature: [`BinarySetFn`][3] and `SplaySetFn`. Here's a sample of using `BinarySetFn` with integer elements:

```sml
structure Main =
  struct
    (*
     * Create an IntSet module by instantiating the BinarySetFn
     * functor with a structure that provides ordering on integers.
     *)
    structure IntSet = BinarySetFn(struct
      type ord_key = int
      val compare = Int.compare
    end)

    fun main () =
      let
        val set1 = IntSet.fromList [1, 2, 3]
        val set2 = IntSet.fromList [2, 3, 4]
        val set3 = IntSet.intersection (set1, set2)
      in
        IntSet.toList set3 (* [2, 3] *)
      end
  end
```

The problem with this approach is that it's functor-based, which means that one has to call the `BinarySetFn` functor for each and every type of element that they want to put in a set data structure. You want a set of strings? Then you call the `BinarySetFn` functor with a structure implementing ordering on strings. You want a set of sets? Same thing: call the functor with an ordering on sets.

This is annoying because it's just too verbose and it's due to the fact that structures are not first-class values. They're part of the module language of Standard ML, which lives separately from the core language of values. Is there a better way? Maybe.

## Type-Indexed Data Structures

At some point I decided I wanted to play around with a different design for such data structures that was not functor-based. The idea was to pass the ordering function as a parameter to the builder functions of the structures. Here's what I mean by that. The current `ORD_SET` signature looks similar to this:

```sml
signature ORD_KEY :
  sig
    type ord_key
    val compare : ord_key * ord_key -> order
  end

signature ORD_SET :
  sig
    structure Key : ORD_KEY

    type set
    type item = Key.ord_key

    val empty : set
    val singleton : item -> set
  end
```

So the ordering function is part of a sub-structure of the signature: `ORD_KEY`. What if instead we'd do this and eliminate the `ORD_KEY` signature entirely?


```sml
signature ORD_SET =
  sig
    type 'a set

    val empty : ('a * 'a -> order) -> 'a set
    val singleton : ('a * 'a -> order) -> 'a -> 'a set
  end
```

Now, the two "factory" functions will take a polymorphic ordering as an argument. The type parameter `'a` will be the type of set elements. Presumably this ordering function will be stored inside a data structure that implements that abstract `set` type. Let's see how this could look like with a naive list-based set.

```sml
structure ListSet :> ORD_SET =
  struct
    type 'a set = {
      compare : 'a * 'a -> order,
      elems : 'a list
    }

    fun empty compare =
      {
        compare = compare,
        elems = []
      }

    fun singleton compare elem =
      {
        compare = compare,
        elems = [elem]
      }
  end
```

The set is represented using a record that stores the elements as a list, together with the ordering function for those elements. We can now add a couple other functions for inserting elements into an existing set and for obtaining the list representation back, which is now held hidden.

```sml
signature ORD_SET =
  sig
    (* continued *)
    val toList : 'a set -> 'a list
    val insert : 'a set -> 'a -> 'a set
  end

structure ListSet :> ORD_SET =
  struct
    (* continued *)
    fun toList { compare, elems } =
      elems

    fun insert { compare, elems } elem =
      let
        fun loop elems =
          case elems of
            [] => [elem]
          | head :: tail =>
              case compare (head, elem) of
                LESS => head :: (loop tail)
              | EQUAL => elems
              | GREATER => elem :: elems
      in
        {
          compare = compare,
          elems = loop elems
        }
      end
  end
```

I won't go in detail over the implementation of `insert`, but, in short, what it does is that it keeps the elements list sorted so that it's easier to find whether an element already exists in the list. It's still naive for a real set implementation that will most likely use a balanced tree, but it'll do. Let's now see how to use it:

```sml
- val intSet = ListSet.empty Int.compare;
- val strSet = ListSet.empty String.compare;
- val set1 = ListSet.insert intSet 1;
- val set2 = ListSet.insert set1 2;
- ListSet.toList set2; (* [1, 2] *)
- ListSet.insert strSet 2;
stdIn:16.1-16.24 Error: operator and operand don't agree [overload conflict]
  operator domain: string
  operand:         [int ty]
  in expression:
    (ListSet.insert strSet) 2
- ListSet.insert intSet "2";
stdIn:1.2-2.10 Error: operator and operand don't agree [tycon mismatch]
  operator domain: int
  operand:         string
  in expression:
    (ListSet.insert intSet) "2"
-
```

## The Problem

As you can see, we didn't have to instantiate any functors here. The set is polymorphic just like a normal list and it's typesafe — one cannot put a string inside an int set or vice-versa. This is nice, but we're just about to hit the actual problem. Let's think how we would go about implementing a common set operation: `union`.

```sml
signature ORD_SET =
  sig
    (* continued *)
    val union : 'a set -> 'a set -> 'a set
  end

structure ListSet :> ORD_SET =
  struct
    (* continued *)
    fun union set1 set2 =
      let
        val { compare = compare1, elems = elems1 } = set1
        val { compare = compare2, elems = elems2 } = set2
      in
        raise Fail "not implemented"
      end
  end
```

I'm not going to fill in the actual implementation because what we have is enough to illustrate the problem. The issue we're facing is that we have two sets, each providing its own `compare` function and there's absolutely no guarantee that these two functions behave the same. For example, the following code typechecks, but it should't, because we're trying to merge sets with different orderings:

```sml
- fun reverseOrd ord (a, b) =
=  case ord (a, b) of
=    LESS => GREATER
=  | EQUAL => EQUAL
=  | GREATER => LESS;
-
- val set1 = ListSet.empty Int.compare;
- val set2 = ListSet.empty (reverseOrd Int.compare);
- val set3 = ListSet.union set1 set2; (* shouldn't compile, but it does *)
```

The same problem can manifest when the ordering function isn't stored as part of the set representation, but it's instead passed as an extra argument to each of the set operations, either explicitly or implicitly, i.e., using type-classes. It's actually even more hideous in that case because it creates problems even for the `insert` operation (imagine two insert calls on the same set instance, but supplying different orderings to each call). This is a problem that can appear in Scala, for example, whose type-class emulation does not guarantee coherence, i.e., a given type can only have a single associated instance of a particular type-class.

So, is there a solution to this problem in SML? Initially I thought there isn't, but a few days ago I realized there might be one, albeit not that simple.

## The Solution

To recap, the problem appears for this call, where we can't statically guarantee that the two set instances carry the same ordering:

```sml
ListSet.union set1 set2
```

One idea of ensuring this property is to somehow tag the orderings through the type system; associate each ordering function with a unique type. We can achive this by wrapping an ordering function in a structure that opaquely exposes the type of the function. And two opaque types are equal only if they're part of the same signature. So, the first step towards opaque types is a signature, which will let us hide the type in the structure(s):

```sml
signature TAGGED_ORD =
  sig
    type t
    val compare : t * t -> order
  end
```

This looks exactly as the `ORD_KEY` signature defined by the SML/NJ library, but we're not done yet. Let's try to use it in a way that wasn't meant to be:

```sml
structure IntOrd :> TAGGED_ORD =
  struct
    type t = int
    val compare = Int.compare
  end
```

Notice the `:>` part where we're specifying that the structure must comply with the signature. The difference between `:` and `:>` is that `:>` will keep the representation of types hidden. In our particular case, it renders the `IntOrd` structure useless. We cannot use it at all:

```sml
- IntOrd.compare (1, 2);
stdIn:35.1-35.22 Error: operator and operand don't agree [overload conflict]
  operator domain: IntOrd.t * IntOrd.t
  operand:         [int ty] * [int ty]
  in expression:
    IntOrd.compare (1,2)
```

This says that `IntOrd.compare` only accepts types `IntOrd.t`, not `int`. We know they're the same, but the compiler does not because of the opaque signature ascription `:>`. What's to do? We need to add a new function to the signature that will let us lift `int` values to `IntOrd.t` values:

```sml
signature TAGGED_ORD =
  sig
    type t
    val wrap : int -> t
    val compare : t * t -> order
  end

structure IntOrd :> TAGGED_ORD =
  struct
    type t = int

    fun wrap a = a
    val compare = Int.compare
  end
```

We can now order integers again:

```sml
- IntOrd.compare (IntOrd.wrap 1, IntOrd.wrap 2);
val it = LESS : order
```

What the `TAGGED_ORD.t` represents now is basically the singleton type of the compare function defined in the structure. There will be no other type that will be equal to it, except itself.

We're still missing a thing, however. The type-indexed `ListSet` module will now need not only a `compare` function, but also a `wrap` function. And because modules aren't first-class values in Standard ML, we cannot pass our `TAGGED_ORD` structures to the `ListSet.empty` function. We need a way to pack those two functions together in a record and pass that instead. So, our final `TAGGED_ORD` signature looks like this:

```sml
signature TAGGED_ORD =
  sig
    type t
    type a
    val wrap : int -> t
    val compare : t * t -> order
    val asRecord : { wrap : a -> t, compare : t * t -> order }
  end
```

Notice that we had to introduce another type, `a`, that will represent the type of values we're lifting from. Now `IntOrd` becomes this (notice that the `a` type is exposed, but `t` is not, through what it's called a translucent signature ascription):

```sml
structure IntOrd :> TAGGED_ORD where type a = int =
  struct
    type t = int
    type a = int

    val wrap = Fn.id
    val compare = Int.compare
    val asRecord = { wrap = wrap, compare = compare }
  end
```

We're now finally ready to change our `ORD_SET` signature and `ListSet` structure to work with this new type of "tagged" orderings:

```sml
signature ORD_SET =
  sig
    type ('a, 'ord_t) set

    type ('a, 'ord_t) compare = {
      wrap : 'a -> 'ord_t,
      compare : 'ord_t * 'ord_t -> order
    }

    val empty : ('a, 'ord_t) compare -> ('a, 'ord_t) set
    val singleton : ('a, 'ord_t) compare -> 'a -> ('a, 'ord_t) set
    val toList : ('a, 'ord_t) set -> 'a list
    val insert : ('a, 'ord_t) set -> 'a -> ('a, 'ord_t) set
    val union : ('a, 'ord_t) set -> ('a, 'ord_t) set -> ('a, 'ord_t) set
  end
```

The `'ord_t` type parameter in `type ('a, 'ord_t) set` represents the unique type associated with a `wrap`/`compare` record. So the set type isn't indexed only on the type of the containing elements, but also on the type of the ordering function. This new type parameter will ensure the type safety we're after.

Here's how the `ListSet` structure needs to change now:

```sml
structure ListSet :> ORD_SET =
  struct
    type ('a, 'ord_t) set = {
      wrap : 'a -> 'ord_t,
      compare : 'ord_t * 'ord_t -> order,
      elems : 'a list
    }

    type ('a, 'ord_t) compare = {
      wrap : 'a -> 'ord_t,
      compare : 'ord_t * 'ord_t -> order
    }

    fun empty { wrap, compare } =
      {
        wrap = wrap,
        compare = compare,
        elems = []
      }

    fun singleton { wrap, compare } elem =
      {
        wrap = wrap,
        compare = compare,
        elems = [elem]
      }

    fun toList { wrap, compare, elems } =
      elems

    fun insert { wrap, compare, elems } elem =
      let
        fun loop elems =
          case elems of
            [] => [elem]
          | head :: tail =>
              case compare (wrap head, wrap elem) of
                LESS => head :: (loop tail)
              | EQUAL => elems
              | GREATER => elem :: elems
      in
        {
          wrap = wrap,
          compare = compare,
          elems = loop elems
        }
      end

    fun union set1 set2 =
      let
        val { wrap = wrap1, compare = compare1, elems = elems1 } = set1
        val { wrap = wrap2, compare = compare2, elems = elems2 } = set2
      in
        raise Fail "not implemented"
      end
  end
```

The most important difference is in the `insert` function, where we need to call `wrap` on the elements that we want to pass to `compare`:

```sml
case compare (wrap head, wrap elem) of
```

The same thing would have to happen in the implementation of `union` as well, but we don't have one yet. All we're interested in is whether illegal calls are refused by the type checker. To check that, let's define yet another ordering on integers, a reverse ordering:

```sml
structure RevIntOrd :> TAGGED_ORD where type a = int =
  struct
    type t = int
    type a = int

    fun reverseOrd ord (a, b) =
      case ord (a, b) of
        LESS => GREATER
      | EQUAL => EQUAL
      | GREATER => LESS

    val wrap = Fn.id
    val compare = reverseOrd Int.compare
    val asRecord = { wrap = wrap, compare = compare }
  end
```

Finally, we can verify whether we can union two sets based on different orderings:

```sml
- val set1 = ListSet.empty IntOrd.asRecord;
val set1 = - : (a,IntOrd.t) ListSet.set
- val set2 = ListSet.empty RevIntOrd.asRecord;
val set2 = - : (a,RevIntOrd.t) ListSet.set
- ListSet.union set1 set2;
stdIn:110.1-110.24 Error: operator and operand don't agree [tycon mismatch]
  operator domain: (a,IntOrd.t) ListSet.set
  operand:         (a,RevIntOrd.t) ListSet.set
  in expression:
    (ListSet.union set1) set2
-
```

Success! Another illegal state made unrepresentable! Also, notice how the error message lets us know that we've been trying to use difference orderings (`IntOrd.t` vs `RevIntOrd.t`):

```
  operator domain: (a,IntOrd.t) ListSet.set
  operand:         (a,RevIntOrd.t) ListSet.set
```

That's all, folks! You can find the final version of the code in this [gist][4].

[0]: {{page.previous.url}}
[1]: http://www.smlnj.org/doc/smlnj-lib/
[2]: http://www.smlnj.org/doc/smlnj-lib/Manual/ord-set.html
[3]: http://www.smlnj.org/doc/smlnj-lib/Manual/binary-set-fn.html
[4]: https://gist.github.com/igstan/d2585427d4911cda667d42615fce6eda
