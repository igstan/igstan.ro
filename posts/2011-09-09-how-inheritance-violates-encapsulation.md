--------------------------------------------------------------------------------
title: How Inheritance Violates Encapsulation
author: Ionuț G. Stan
date: September 09, 2011
--------------------------------------------------------------------------------

I've recently finished reading [Effective Java][1], and in this book Joshua Bloch
gives a simple demonstration on how inheritance can break encapsulation. That
composition should be favoured over inheritance is a thing I hear quite a lot and
I'm actually trying to follow the rule myself, but I never had a thorough understanding
as to why inheritance would be a bad thing besides the fact that certain languages
don't allow multiple inheritance (a problem I hit in the past).

Joshua Bloch actually makes a good example of a situation where inheritance forces
the developer of the subclass to know about the internals of the superclass, which
means the encapsulation in the superclass is broken. I've put his example in a
small JUnit test case:

~~~{.java}
public class BrokenEncapsulationTest {

  @Test
  public void testAddCount() {
    InstrumentedHashSet<String> set = new InstrumentedHashSet<String>();

    set.addAll(Arrays.asList("Snap", "Crackle", "Pop"));

    assertEquals(3, set.addCount);
  }

  public static class InstrumentedHashSet<E> extends HashSet<E> {

    public int addCount = 0;

    @Override
    public boolean add(E a) {
      addCount += 1;
      return super.add(a);
    };

    @Override
    public boolean addAll(Collection<? extends E> c) {
      addCount += c.size();
      return super.addAll(c);
    }
  }
}
~~~

The above test fails with this message:

> java.lang.AssertionError: expected:<3> but was:<6>

It is entirely non-obvious why `addCount()` would return 6 instead of 3. After all,
we only added three elements, right? The answer is that `HashSet.addAll()` uses
internally the `add` method. This means, that inside `InstrumentedHashSet` we
add 3 to `addCount` inside our overridden version of `addAll`, and then we add 1
three more times to `addCount` for each call to `add` that `super.addAll` executes.

This is such a simple and effective demonstration for a case when you really have
to dig up the source of the parent class in order to find out the cause for the
unexpected behaviour.


Inheritance Overflow
--------------------

Here's another weird case I came across two times in my developer life. Once a
couple of years ago while developing a PHP application, and once a few weeks ago
in a Java application. If you try to run the example below you'll get a
`StackOverflowError`.

~~~ {.java}
public class InheritanceOverflow {

  public static class Parent {

    public void foo() {
      bar();
    }

    public void bar() {}
  }

  public static class Child extends Parent {
    @Override
    public void bar() {
      // I have no idea that foo in Parent is actually calling bar, that calls
      // this method, which will call foo againg, and so on. Infinite recursion.
      foo();
    }
  }

  public static void main(String[] args) {
    new Child().bar();
  }
}
~~~

Unexpected, isn't it? As I said, I'm not making up these examples just to find
weak spots about inheritance. I actually had to debug stuff like this.

Solutions
---------

So, what's to be done about this kind of problems? The best approach would be to
use composition. This basically translates to using the Decorator pattern. For
example, `InstrumentedHashSet` can be rewritten like this:

~~~ {.java}
public static class InstrumentedHashSet<E> implements Set<E> {

  private final Set<E> wrappedSet;

  public int addCount = 0;

  public InstrumentedHashSet(Set<E> wrappedSet) {
    this.wrappedSet = wrappedSet;
  }

  @Override
  public boolean add(E e) {
    addCount += 1;
    return wrappedSet.add(e);
  }

  @Override
  public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return wrappedSet.addAll(c);
  }

  // Other methods required by the Set interface, whose implementation
  // just delegate to the wrappedSet member. Skipped for brevity.
}
~~~

If, for whatever reason, you decide you want your class to be inherited, then
make sure overridable methods don't call other overridable methods. Have them
use either private helper methods, or make those helper methods final if you
want to allow more relaxed visibility rules.

~~~ {.java}
public class InheritanceOverflowRevisited {

  public static class Parent {

    public void foo() {
      barHelper();
    }

    public void bar() {
      barHelper();
    }
    
    public void barHelper() {
      // do bar stuff
    }
  }

  public static class Child extends Parent {
    @Override
    public void bar() {
      foo(); // no more StackOverflowError
    }
  }

  public static void main(String[] args) {
    new Child().bar();
  }
}
~~~

References
----------
- [Effective Java (2nd edition)][1], Item 16: Favor composition over inheritance


[1]: http://www.amazon.com/Effective-Java-2nd-Joshua-Bloch/dp/0321356683
