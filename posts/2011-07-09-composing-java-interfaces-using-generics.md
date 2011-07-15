--------------------------------------------------------------------------------
title: Composing Java Interfaces Using Generics
author: Ionuț G. Stan
date: July 09, 2011
--------------------------------------------------------------------------------

A few months ago I noticed an interesting aspect of the Java programming language.
Everyone knows that a certain class can implement multiple interfaces in Java, but
how would you specify in client code that you expect an instance of an object that
implements multiple interfaces, without using the concrete type?

Say for example that you create a `QueueSet` class which implements both `Queue<T>`
and `Set<T>`.

~~~ {.java}
public class QueueSet<T> implements Queue<T>, Set<T> {
  // methods required by Queue and Set
}
~~~

Now, some client code needs such a `QueueSet<T>`. What are its options? It could
require an instance of `QueueSet<T>` in the method signature...

~~~ {.java}
public <T> void foo(QueueSet<T> queueSet) {}
~~~

It works, but if `foo` is itself part of a library, it would want to be as generic
as possible, and as such depend on an interface rather than a concrete class. The
obvious answer for this problem is to make `QueueSet` an interface, and rename the
initial concrete class to something else.

~~~ {.java}
public interface QueueSet<T> extends Queue<T>, Set<T> {}

public class PeculiarQueueSet<T> implements QueueSet<T> {
  // methods required by QueueSet, i.e. Queue and Set
}
~~~

The problem here is that any other class that implements `Queue<T>` and `Set<T>`,
but doesn't implement `QueueSet<T>`, won't satisfy the type signature of `foo`. It's
a shame that we had to create a wrapper interface just for this. It would have been
better to be able to specify inside `foo`, that the `queueSet` parameter is expected
to be an instance of an object that implements both `Queue<T>` and `Set<T>`, without
any additional wrapper interface. Something like this:

~~~ {.java}
public <T> void foo(Queue<T> and Set<T> queueSet) {}
~~~

The idea came to me from Haskell's typeclasses, which allow a notation similar to
the one above when you want to enforce a particular type variable to be an instance
of multiple typeclasses.

~~~ {.haskell}
foo :: (Ord a, Show a) -> [a] -> [a]
foo list = -- implementation
~~~

So, my first thought was that Java does not permit this level of abstraction, but
I was wrong. A couple of days ago, while playing with some generics, I rediscovered
that Java's generics allow multiple bounded type parameters. So, the generic version
of `foo` that satisfies our needs would be this:

~~~ {.java}
public <T, QS extends Queue<T> & Set<T>> void foo(QS queueSet) {}
~~~

My wishful thinking about `Queue<T> and Set<T>` transformed into `QS extends Queue<T>
& Set<T>`. You can rename `QS` to whatever you want. I chose a two letter type variable
as a means to convey that it uses multiple type bounds, i.e., both `Queue<T>` and
`Set<T>`.

Regarding the syntax. Well, yes, I agree it is unnecessarily verbose, but at least
it's possible. Although, on a second thought, the real problem is that the type
declarations are interleaved with the method name and the formal parameter names.
Haskell code seems more legible, to me at least, just because it separates the
function signature from its implementation.

References
----------
- Gilad Bracha's [Generics in the Java Programming Language][1]
- [Bounded Type Parameters][2]

[1]: http://java.sun.com/j2se/1.5/pdf/generics-tutorial.pdf
[2]: http://download.oracle.com/javase/tutorial/java/generics/bounded.html
