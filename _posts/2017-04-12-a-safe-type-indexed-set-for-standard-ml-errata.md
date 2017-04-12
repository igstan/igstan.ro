---
title: A Safe Type-Indexed Set for Standard ML, Errata
author: Ionuț G. Stan
date: April 12, 2017
---

It turns out that my [contraption on how to make a type-indexed set safe in Standard ML][0] doesn't actually work. It gives the illusion that the type system will prevent that kind of usage errors, but it actually won't. You still need discipline. Here's a very short example that breaks the solution. It's based on the code that's available in [this gist][1]:

```sml
- use "set.sml";
-
- fun reverseOrd ord (a, b) =
…   case ord (a, b) of
…     LESS => GREATER
…   | EQUAL => EQUAL
…   | GREATER => LESS;
-
- val set1 = ListSet.empty { wrap = Fn.id, compare = Int.compare };
-
- val set2 = ListSet.empty { wrap = Fn.id, compare = reverseOrd Int.compare };
-
- ListSet.union set1 set2; (* it typechecks... :( *)
```

So, if someone creates their own record, without going through an `asRecord` call, then the problem reappears. It can appear even without an `asRecord` call if the tagging type isn't hidden properly, i.e., made opaque via an opaque signature ascription: `:>`.

Is there an actual solution then? I've spent some brain cycles thinking about this and my answer so far is that there isn't. The main, technical reason is that SML provides type generativity only at the functor-level, not at the function-level. Here's what I mean by this.

## Type Generativity

Functors in SML are generative, which means that exposed opaque types are different between different function invocations. We need a signature first, otherwise we can't hide the exposed types.

```sml
signature FOO =
  sig
    type t

    val foo : t
  end
```

Now we can write a zero argument functor that produces `FOO` structures where `t` is hidden/opaque due to `:>`:

```sml
functor Foo() :> FOO =
  struct
    type t = unit

    val foo = ()
  end
```

Let's try to use it now:

```sml
- structure F1 = Foo();
- structure F2 = Foo();
-
- val a = ref (F1.foo);
val a = ref - : F1.t ref
- a := F2.foo;
stdIn:17.1-17.12 Error: operator and operand don't agree [tycon mismatch]
  operator domain: F1.t ref * F1.t
  operand:         F1.t ref * F2.t
  in expression:
    a := F2.foo
```

As you can see, this is a type error, the type `F1.t` is seen as different from the type `F2.t`. This feature, where a functor produces different opaque types with each invocation is called generativity. There's no way to have non-generative functors in SML.

Back to the problem. What does generativity have to do with our initial problem? The crux of it is that we need to attach unique types to each ordering function we might come up with and the only way to produce unique types in Standard ML is via generativity, i.e., functors. So we need to pass the ordering function as an argument to some functor and have the functor produce a uniquely typed ordering function.

In conclusion, if we want typesafe `union` operations on sets, we need functors. And thus, my previous blog post is useless. The only thing it helped me with is that I learned a bunch of new stuff. Sorry for the confusion.

[0]: {{page.previous.url}}
[1]: https://gist.github.com/igstan/d2585427d4911cda667d42615fce6eda
