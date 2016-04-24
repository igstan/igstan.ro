--------------------------------------------------------------------------------
title: Typeclasses In Scala
author: Ionuț G. Stan
date: December 29, 2012
--------------------------------------------------------------------------------

Here's a common object-oriented problem in OO languages such as Java.
You're using two libraries. One of them provides a class, say `Foo`, which performs
some useful tasks. The other library provides a useful `bar` method that takes
as an argument instances of `Barable`, an interface. You've got no control on
either of the two libraries, but you'd like to be able to pass an instance of
`Foo` to the `bar` method. Let's image it would save you a lot of work to do
this. However you can't. `Foo` doesn't implement `Barable` and you can't modify
`Foo` to have it implement the aforementioned interface. The normal solution
involves writing a wrapper class around `Foo` that implements `Barable`, an
adapter.

~~~java
public void bar(Barable barable) {
  barable.barring();
}
~~~

~~~java
class FooWrapper implements Barable {
  private final Foo foo;

  public FooWrapper(Foo foo) {
    this.foo = foo;
  }

  public void barring() {
    foo.stuff();
  }
}
~~~

You can now use it like this:

~~~java
bar(new FooWrapper(new Foo()));
~~~

Had you been in control of the library that provides `Barable` you would have
been able to separate these two concerns by having the `bar` method taking two
arguments. The first one the object it needs, and the second one the object
that implements `Barable`.

~~~java
public <A> void bar(A a, Barable<A> barable) {
  barable.barring(a);
}
~~~

This is pretty similar to the first solution. The difference is that the `bar`
method is now responsible for passing the wrapped object to the object that
implements `Barable`. In the first solution we pass `Foo` as an argument to the
constructor of `FooWrapper`. In the second solution `bar` passes its first
argument when it calls `Barable.barring`. Not necessarily an improvement, but
you'll understand in a minute why I proposed this solution as well.s

A common idiom in Scala is to employ the second solution but with a twist.
Instead of manually passing the second argument to the `bar` method, i.e. the
one implementing `Barable`, you instead tell the compiler to pass it **implicitly**
using implicit parameters. Implicit parameters are just that, parameters that
are not passed explicitly. They're passed _implicitly_ by the compiler. How does
it know what to pass? Well, there are two places you'll have to use the `implicit`
keyword in order to make this work. First, when defining a method that you'd like
to receive implicit parameters, you need to declare a separate parameter list
of implicit params.

~~~scala
def bar[A](a: A)(implicit barable: Barable[A]): Unit = {
  // ...
}
~~~

Then, whenever you or someone else uses the `bar` method an object of the
appropriate type (`Barable` in this case) must be in case, and furthermore,
be marked as an implicit object when it's defined.

~~~scala
implicit object FooBarable extends Barable[Foo] {
  // ...
}
~~~

If the `FooBarable` object is in scope (and the scope resolution rules are
quite involved for this particular case in Scala) and marked as implicit, then
the compiler will automatically passed it as the second argument to the `bar`
method.

~~~scala
bar(new Foo())
~~~

You can of course pass the instance explicitly if that's what you want, or any
other instance for that matter.

~~~scala
bar(new Foo())(FooBarable)
~~~

This `Barable[A]` which I've alluded to above is a Scala trait and the way it's
supposed to be used makes it a typeclass.

~~~scala
trait Barable[A] {
  def barring(a: A): Unit
}
~~~

What do I mean by "the way it's supposed to be used". I mean that this trait
will appear as a type annotation for implicit parameters in methods that depend
on this `Barable` interface/trait.

~~~scala
def bar[A](a: A)(implicit barable: Barable[A]): Unit = {
  // ...
}
~~~

This is instead of the original scenario when we started where `bar` depended
just on `Barable` alone.

~~~scala
def bar(barable: Barable): Unit = {
  // ...
}
~~~

Does this help us in any way? Yes. Most of the time there's a mismatch between
the type you have and the interface some method would expect. For example in
a JSON library. You'd like to be able to serialize Ints, Strings, Booleans, or
other user-defined types. A library defining a `writeJson` method has three
choices with regard to its implementation:

1. Have the method take only instances which implement some `WriteJson` trait.
   The method would then delegate to some other method defined in that trait.
   The disadvantage is the one I've started my blog post with. Some types are
   closed and we can't redefine new methods on them.
2. Do a type dispatch inside the method. Check for the type of the received
   argument and serialize according to that type. The problem here is that
   you won't be able o use types the library hasn't accounted for. Not so nice.
3. Use the typeclass pattern. Have the `writeJson` method take a second param,
   an implicit one, which knows how to do the serialization. The method can now
   pass its first argument to the second. Basic delegation. The advantage? The
   library can come with predefined implicit objects for common types such as
   Int, String, or Boolean, while still allowing the user to add support for
   new types by means of writing an implicit object implementing the required
   trait. This is what Play! framework does, by the way.

Employing the first choice isn't much different than the third one if the library
ships with wrappers for common types, but it will still be cumbersome to
manually wrap them everytime using the approapriate wrapper. And you'll have to
know about the wrappers. With implicit params all you have to do to use the
library with common types is to import the implicit objects. This is usually
achieved using a wildcard import, like `import play.api.libs.json._`.
