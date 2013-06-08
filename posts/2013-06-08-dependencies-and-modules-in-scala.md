--------------------------------------------------------------------------------
title: Dependecies and Modules In Scala
author: Ionuț G. Stan
date: June 08, 2013
--------------------------------------------------------------------------------

I've watched [two][0] [presentations][1] on how traits make for a "really, really,
really" awesome module system in Scala, while:

> Dependency Injection is like a poor man's module system that isn't typechecked.

I'd like to know what was meant by Dependency Injection there, because in my
world <abbr title="Dependency Injection">DI</abbr> is just as typechecked.
I understand Scala is the new shit, and the ability to bake enormous [cakes][3]
is tantalizing, but seriously... let's stop the hand waving. Describing something
as being "really, really, really intersting", "profound", or whatever won't prove
anything.

Why is the cake pattern better than the "classical" constructor-based injection?
How isn't a simple interface/trait better than this contraption using nested
traits, abstract type aliases, and long lists of traits being mixed in. Or...
ok, let me rephrase it. **When** is the cake pattern better than "classical"
constructor-based injection? I have yet to see a convincing answer. On the other
hand, I can tell you when the cake pattern is categorically weaker than normal
constructors.

But maybe people are not aware of constructor based injection... I can't blame
them though, given that Spring has tried very hard to hide this behind their
bloated XML files. One thing that might help in accepting this type of DI is to
think of it as a partial application over a collection of related functions.
I'm sure you've heard this one before, right?

Here's what I mean by "classical", constructor-based, injection. We've got a
`Cache` trait and two concrete implementations, one based on Mongo and one
based on Redis.

```scala
trait Cache[K, V] {
  def get(k: K): Option[V]
  def set(k: K, v: V): Cache[K, V]
}

class MongoCache[K, V]() extends Cache[K, V] {
  override def get(k: K) = ???
  override def set(k: K, v: V) = ???
}

class RedisCache[K, V]() extends Cache[K, V] {
  override def get(k: K) = ???
  override def set(k: K, v: V) = ???
}
```

We've also got two abstract repositories for students and teachers.

```scala
trait StudentRepository {
  def all: Seq[Student]
  def get(id: String): Option[Student]
}

trait TeacherRepository {
  def all: Seq[Teacher]
  def get(id: String): Option[Teacher]
}
```

There are two implementations of them that support caching, which can be inferred
by observing the constructor arguments.

```scala
/**
 * A PostgreSQL backed implementation that supports caching. Notice how
 * the cache dependency is passed through the constructor.
 */
class PostgresStudentRepository(cache: Cache[String, String]) extends StudentRepository {
  override def all = ???
  override get get(id: String) = ???
}

/**
 * Same thing as with PostgresStudentRepository.
 */
class PostgresTeacherRepository(cache: Cache[String, String]) extends StudentRepository {
  override def all = ???
  override get get(id: String) = ???
}
```

Now that we have some components, let's build the graph of objects/modules and
let the whole system run.

```scala
class Main {
  def main(args: Array[String]): Unit = {
    val mongoCache = new MongoCache[String, String]
    val redisCache = new RedisCache[String, String]
    val studentRepository = new PostgresStudentRepository(mongoCache)
    val teacherRepository = new PostgresTeacherRepository(redisCache)

    // Both repositories can now be passed to some other components
    // via constructor injection.
    val system = new System(studentRepository, teacherRepository)
    system.start()
  }
}
```

Try to do the same thing using the cake pattern. You'll quickly discover that
you won't be able to provide two different implementations for the `Cache`
module. And that's because in the end, when you wire together all those modules
you mix together all trait members into the same "namespace" (I use it with
the literal meaning here, a space for names, not with the meaning of "package").


```scala
trait CacheModule {
  type Cache[K, V] <: CacheLike[K, V]

  def Cache[K, V]: Cache[K, V]

  trait CacheLike[K, V] {
    def get(k: K): V
    def set(k: K, v: V): Cache[K, V]
  }
}

trait MongoModule extends CacheModule {
  override def Cache[K, V] = new Cache[K, V]

  class Cache[K, V] extends CacheLike[K, V] {
    override def get(k: K): V = ???
    override def set(k: K, v: V): Cache[K, V] = ???
  }
}

trait RedisModule extends CacheModule {
  override def Cache[K, V] = new Cache[K, V]

  class Cache[K, V] extends CacheLike[K, V] {
    override def get(k: K): V = ???
    override def set(k: K, v: V): Cache[K, V] = ???
  }
}

trait StudentRepositoryModule {
  type StudentRepository <: StudentRepositoryLike

  def StudentRepository: StudentRepository

  trait StudentRepositoryLike {
    def all: Seq[Student]
    def get(id: String): Option[Student]
  }
}

trait TeacherRepositoryModule {
  type TeacherRepository <: TeacherRepositoryLike

  def TeacherRepository: TeacherRepository

  trait TeacherRepositoryLike {
    def all: Seq[Teacher]
    def get(id: String): Option[Teacher]
  }
}

trait PostgresStudentRepositoryModule extends StudentRepositoryModule {
  self: CacheModule =>

  override def StudentRepository = new StudentRepository

  class StudentRepository extends StudentRepositoryLike {
    override def all: Seq[Student] = ???
    override def get(id: String): Option[Student] = ???
  }
}

trait PostgresTeacherRepositoryModule extends TeacherRepositoryModule {
  // This module needs a CacheModule. Just as in the non-cake case, when
  // the TeacherRepository's constructor required a Cache instance, in
  // this case we declare our dependency on caching using a self-type.
  self: CacheModule =>

  override def TeacherRepository = new TeacherRepository

  class TeacherRepository extends TeacherRepositoryLike {
    override def all: Seq[Teacher] = ???
    override def get(id: String): Option[Teacher] = ???
  }
}
```

This is where it gets interesting. Notice how we can't provide a `RedisCacheModule`.

```scala
class Main {
  def main(args: Array[String]): Unit = {
    val app = new System with PostgresStudentRepositoryModule
                         with PostgresTeacherRepositoryModule
                         with MongoCacheModule
                      // with RedisCacheModule is impossible...
  }
}
```

I agree the cake pattern looks cool, but I haven't seen solid arguments for
adopting it. It seems it's cooler just because it uses quite a few JVM-novel
language features, like traits, trait composition at call site, and self-types.

Both of these approaches are just as typesafe. Also, in my opinion, the former
approach is easier to comprehend because it's an old pattern, but that's not
quite a good argument, as time will easily solve this issue. However, as you've
noticed, the cake pattern is imposing a serious limitation on how many different
implementations you can provide for a single trait.

Another point is that both objects created from traits, as well as objects
created from classes are objects, i.e. first-class values. You can still use
classes and constructor-based DI if you like this idea of first-class modules.
A class would be just a factory for modules.

There is however a particular case enabled by the cake pattern, which looks
impossible to achieve using normal classes, and that is **abstract interface
composition**.

I'm not sure how clearly I can describe this, but... in the above example, you
can imagine that the implementation of `PostgresStudentRepository.get` will
first verify the `cache` and just when there's no value in the cache it will
actually execute a database query. This piece of caching logic can be abstracted
away, but notice that it depends on two traits: `Cache` and `StudentRepository`.
What can we use in Scala to declare these dependencies? Self-types, of course:

```scala
/**
 * This trait provides the caching boilerplate, but leaves undefined
 * the mechanism that provides a fresh, non-cached, Student. Also, we
 * don't specify anything about the implementation of Cache. These are
 * the two interfaces: StudentRepository.slowGet and Cache.get that
 * we're composing within this trait.
 */
trait CachingStudentRepository extends StudentRepository {
  self: Cache =>

  override def get(id: String): Option[Student] = {
    self.get(id).map(makeStudent(_)).orElse(slowGet(id))
  }

  def slowGet(id: String): Option[Student]
}
```

The only way I can see this implemented without using the cake pattern is by
replacing the self-type with an abstract cache member:

```scala
trait CachingStudentRepository extends StudentRepository {
  def cache: Cache

  override def get(id: String): Option[Student] = {
    cache.get(id).map(makeStudent(_)).orElse(slowGet(id))
  }

  def slowGet(id: String): Option[Student]
}
```

This will still cause namespacing issues if a `CachingTeacherRepository` will
declare an abstract `cache` member as well. It's actually the same problem that
the cake patterns suffers from. You won't be able to provide different
implementations for the same interface.

A simple solution is to prepend, or append, the trait name to the member:
`cachingStudentRepositoryCache`. Not so nice, eh? It would be nice if Scala
would allow us to rename members inherited from traits, like say... [PHP 5.4
does][4], a language everybody loves to hate:

```php
<?php

trait A {
  public function smallTalk() {
    echo 'a';
  }
  public function bigTalk() {
    echo 'A';
  }
}

trait B {
  public function smallTalk() {
    echo 'b';
  }
  public function bigTalk() {
    echo 'B';
  }
}

class Talker {
  use A, B {
    B::smallTalk insteadof A;
    A::bigTalk insteadof B;
  }
}

class Aliased_Talker {
  use A, B {
    B::smallTalk insteadof A;
    A::bigTalk insteadof B;
    B::bigTalk as talk;
  }
}
```

The Cake Pattern. When?
-----------------------
Okay, that was my little rant concerning the cake pattern. I believe people give
it too much credit for no added benefit over what we were already able to do in
Java. Any counter-argument will be greatly appreciated. I haven't written this
blog post to prove someone is wrong. I actually wrote it so that I know what's the
best tool for the job. And when it comes to DI in Scala, I see no clear arguments
that the cake pattern is best for me.

Oh... I'm lying. There's actually a situation when there's no other choice. That's
when you have no control over your own constructors, e.g., the Servlet API.
Or when you don't even have constructors, e.g. Play! Framework controller objects
(enforcing objects in Play! is again something I don't see a good reason for,
but that's another blog post I guess).

So, I'm curious to see a clear example of when I'll really have to use the
cake pattern, because constructor-based injection won't handle the issue.

Unexplored Grounds
------------------
There are two things I haven't yet explored in this post:

1. Whether any of these two DI patterns helps or hinders an immutable style
2. Left-most currying vs. right-most currying DI, where left-most currying
   is represented by constructor-based injection, and right-most currying
   is represented by the [reader monad][2]. This is also a subject for a
   future blog post.


Resources
---------
- Videos
    - [Cake Pattern: The Bakery from the Black Lagoon ][0]
    - [Living in a Post-Functional World][1]
    - [Dead-Simple Dependency Injection is Scala][2]

- Articles
    - [Real-World Scala: Dependency Injection (DI)][3]
    - [Cake pattern in depth](http://www.cakesolutions.net/teamblogs/2011/12/19/cake-pattern-in-depth/)
    - [Dependency Injection vs. Cake pattern](http://www.cakesolutions.net/teamblogs/2011/12/15/dependency-injection-vs-cake-pattern/)
    - [Guide: Writing Testable Code](http://misko.hevery.com/code-reviewers-guide/)
    - [Where Have All the Singletons Gone?](http://misko.hevery.com/2008/08/21/where-have-all-the-singletons-gone/)

[0]: http://www.youtube.com/watch?v=yLbdw06tKPQ
[1]: http://2013.flatmap.no/spiewak.html
[2]: http://marakana.com/s/post/1108/dependency_injection_in_scala
[3]: http://jonasboner.com/2008/10/06/real-world-scala-dependency-injection-di/
[4]: http://php.net/manual/ro/language.oop5.traits.php
