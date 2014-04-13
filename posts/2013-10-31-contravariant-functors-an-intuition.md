--------------------------------------------------------------------------------
title: Contravariant Functors — An Intuition
author: Ionuț G. Stan
date: October 31, 2013
--------------------------------------------------------------------------------

Today I came across a [blog post listing different types of functors][0] (expressed
using Scala), and once again I found a mention of contravariant functors. I
heard about them in the past, saw their signature, but... no epiphany.

In this post I'd like to gain an intution for what a contravariant functor is.
I'll leave it for another post to understand the other scary one, the exponential
functor (shouldn't be much harder I presume, seems to be composed of two other
functors — one covariant, the other contravariant).

Here's the signature given for contravariant functor in the above blog post:

```scala
trait Contravariant[F[_]] {
  def contramap[A, B](f: B => A): F[A] => F[B]
}
```

It's pretty mind bending (for me) to understand how that `f` function can possibly
get a handle over a value of type `B` when `B` can't be found in the argument list,
only in the return type (as opposed to `A`). What's going on then?


A Concrete Example
------------------
After a brief search on the internet I found out that a good example of a
contravariant functor can actually be seen in the Scala standard library.
[`Ordering.by`][3] is a `contramap` incarnation, specialized for instances of
`Ordering`.

```scala
def by[T, S](f: T => S)(implicit ord: Ordering[S]): Ordering[T]
```

The signature looks a bit different that the one used by Tony Morris, but they're
the same conceptually (the former is just more general). What it says is that if
you know how to compare elements of type `S` and you have a function relating
elements of type `T` to elements of type `S`, then you know how to compare elements
of type `T`.

There are two conceptual mappings here. At a higher-level you want to map
`Ordering[S]` to `Ordering[T]`, but in order to achieve that an opposite mapping
is required — from `T` to `S` — hence "contra".

Generalizing we get that `contramap` is a function which says that if you give
it some abstraction over a concept `A`, i.e., `F[A]`, and a function that maps
from a different concept `B` to the concept `A`, then it is able to give you back
an abstraction over `B`, i.e., `F[B]`. Pretty abstract maybe, but bear with me.


Intuition
---------
Here's a simple real world example inspired by [this thread][4].

Everybody knows how to compare numbers, right? 2 is smaller than 3, 3 is greater
than 2. Also, everybody knows what money are. It's a concept we've been using for
ages now, and it's pretty trivial to draw a correspondence between money and
numbers. We'd map a one dollar bill (100 cents) to the number 100 for example.

Because we know these two things: 1. how to compare numbers; 2. how to map from
money to numbers, we can actually compare money. Obvious, right? Well, calling
`contramap` using those two facts as arguments will provide you the knowledge of
how to compare money. That's exactly the knowledge that a contravariant functor
encodes, but in a more general way, not only for numbers, money and comparisons.

As I said, the final goal is to actually map `F[A] => F[B]`, but in order to
achieve that we need a function that maps `B => A`, i.e. the opposite (contra)
direction. It's basic abstraction. You build new abstraction out of old ones by
specifying relationships between concepts.


Translating to Scala
--------------------
Let's put the above example in Scala code. First, let's represent `Money`:

```scala
case class Money(amount: Int)
```

Scala already knows how to compare `Int`s and based on that knowledge we want to
specify how `Money` should be compared, i.e., derive `Ordering[Money]` from
`Ordering[Int]`. To achieve that, we need a way to specify which sub-component
of `Money` is our desired `Int`, which is trivial in this example:

```scala
val contramapFn: Money => Int = (money) => money.amount
```

Having defined that, and given that an implicit instance for `Ordering[Int]` is
already in scope, all we need now is to call the `contramap` function defined on
the `Ordering` object, namely, the `by` method. The resulted `Ordering[Money]`
is marked as being implicit because we want the compiler to use it when we use
the comparison method `<`.

```scala
implicit val moneyOrd: Ordering[Money] = Ordering.by(contramapFn)
```

Now we can easily compare `Money` instances (we still need an implicit conversion
from `Ordering` to `Ordered` in scope, hence the first import):

```scala
scala> import scala.math.Ordered._
import scala.math.Ordered._

scala> Money(13) < Money(20)
res0: Boolean = true

scala> Money(23) < Money(20)
res1: Boolean = false
```


Implementing `by`
-----------------
How is `Ordering.by` implemented though? One possible implementation looks like
this (the [real one][3] is a bit more complicated due to optimizations):

```scala
def by[T, S](f: T => S)(implicit ord: Ordering[S]): Ordering[T] =
  new Ordering[T] {
    def compare(x:T, y:T) = Ordering[S].compare(f(x), f(y))
  }
```

As you can see, it creates an `Ordering` instance whose `compare` method simply
delegates to the `compare` method of the known `Ordering[S]`, but **not before**
transforming the `x` and `y` parameters by passing them through `f`.

This simple implementation also gives an idea of how `f` is able to receive an
argument of type `T`. It creates a new "function" that will receive `T`s and
inside that "function" will we have access to these `T`s to pass to `f`. When you
need a value of a specific type and you don't have it, what do you do? You return
a function that asks for one. In this particular case we don't have a proper
function, but an object (an instance of `Ordering`), which is nothing more than
a collection of functions, so the reasoning holds.


Conclusion
----------
There are a few more concrete implementation of contravariant functors in the
pages I've linked to in the [resources section](#resources) below, but the
principle remains the same — you build new abstractions out of old ones by
providing a mapping function from the new concept being abstracted to the old
one that has already been abstracted.


Resources
---------

- [Functors and things using Scala][0]
- [I love profunctors. They're so easy.][1]
- [Contravariant functors package][2] on Hackage

[0]: http://tmorris.net/posts/functors-and-things-using-scala/index.html
[1]: https://www.fpcomplete.com/school/to-infinity-and-beyond/pick-of-the-week/profunctors
[2]: http://hackage.haskell.org/package/contravariant-0.4.4/docs/Data-Functor-Contravariant.html
[3]: https://github.com/scala/scala/blob/v2.10.3/src/library/scala/math/Ordering.scala#L218
[4]: http://www.scala-lang.org/old/node/3819.html
