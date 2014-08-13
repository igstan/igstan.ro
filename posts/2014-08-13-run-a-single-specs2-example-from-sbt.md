--------------------------------------------------------------------------------
title: Run a single specs2 example from sbt
author: Ionuț G. Stan
date: August 13, 2014
--------------------------------------------------------------------------------

Every now and then I need to run an single failing specs2 test from the sbt
command line. Because it happens so seldom, though, I keep on forgetting how to
do it. Google isn't very helpful either because I have to remember the specs2
terminology, i.e., specification vs example, when searching.

In this blog post I'll work with the following test:

```scala
package com.example.quux

import org.specs2.mutable._

// This class represents a **specification**.
class ExampleSpec extends Specification {
  "this is a group of example" should {
    "this is example one" in {
      true must be(true)
    }

    "this is example two" in {
      true must be(true)
    }
  }
}
```

## Running a Single Specification

If you're interested in running all the *examples* in the `ExampleSpec`
*specification*, the following sbt command will do.

<pre class="terminal">sbt&gt; testOnly com.example.quux.ExampleSpec</pre>

Or, using a wildcard for the package name, which is what I personally prefer.

<pre class="terminal">sbt&gt; testOnly *ExampleSpec</pre>

## Running a Single Example

If, on the other hand, you'd like to run just the *example* named `this is
example two`, you have to make use of the `-ex` specs2 flag. Please note, this
argument only works with the specs2 testing framework. ScalaTest supports a
different [set of arguments][1].

<pre class="terminal">sbt&gt; testOnly -- -ex "this is example two"</pre>

This works, but the reporter will show even the names of the groups that haven't
been run, which makes it hard to figure out where's the actual failed test.
For this reason, the command I'm actually using is akin to this one:

<pre class="terminal">sbt&gt; testOnly *ExampleSpec -- -ex "this is example two"</pre>

**NB**: you have to wrap the example name in double quotes. Single quotes won't
do it.


[0]: http://stackoverflow.com/questions/13798193/how-do-you-run-only-a-single-spec2-specification-with-sbt
[1]: http://www.scalatest.org/user_guide/using_the_runner
