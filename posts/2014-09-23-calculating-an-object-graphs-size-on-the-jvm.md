--------------------------------------------------------------------------------
title: Calculating an Object Graph's Size on the JVM
author: Ionuț G. Stan
date: September 23, 2014
--------------------------------------------------------------------------------

Here's a little something I learned today. Recently, I had the task of adding an
in memory cache for an exchange rate web service to the project I'm working on.
I've used Guava's `CacheBuilder` and set some random values for its maximum size
and expiry periods. And the I got wondering, what would be the amount of memory
this cache will need when full?

I had a faint idea, from Twitter, that a tool called [jol (Java Object Layout)][0]
might be exactly what I needed, but I wasn't exactly sure. I investigated and,
sure enough, it is a very good tool for finding not only the memory size of an
object graph, but also how objects are laid out in memory on different JVMs. This
later feature is useful when optimizing for CPU caches, but I've got no experience
with this yet.

Back to the subject of this blog post — finding the total amount of memory for
an object graph — things are actually quite simple.

## Add Dependency

First, you want to add jol as a dependency in your favourite build system. I'm
using sbt here.

```scala
libraryDependencies += "org.openjdk.jol" % "jol-core" % "1.0-SNAPSHOT" % "compile"
```

As you may have noticed, I've declared this dependency as compile time only. We
need it during interactive development, but not (yet) at runtime.

## Start Exploring

Next, fire up `sbt console` and try these commands:

```scala
import org.openjdk.jol.info.GraphLayout

println(GraphLayout.parseInstance("USD").toFootprint)
println(GraphLayout.parseInstance("USD").toPrintable)
println(GraphLayout.parseInstance("USD" -> "EUR").totalSize)
```

Here's the output I got when inspecting a simple tuple value.

<pre class="terminal">
scala&gt; println(GraphLayout.parseInstance("USD" -&gt; "EUR").toFootprint)
scala.Tuple2 instance footprint:
 COUNT   AVG   SUM DESCRIPTION
     2    24    48 [C
     2    24    48 java.lang.String
     1    24    24 scala.Tuple2
     5         120 (total)
</pre>

In the first column we have an instance count per class: two instances of type
`[C` or `Array[Char]`, two instance of type `String` and one instance of type
`Tuple2`.

The third column shows how much memory all the instance of a particular type
occupy. The char arrays and the strings occupy 48 bytes each. The tuple takes
24 bytes. They all add up to a total memory size of 120 bytes.

The average column says what amount of memory is consumed, on average, by each
instance. Why on average though? I don't have an answer to this yet, but I
presume is becuse of byte alignment rules.

Another question might be why does a single `String` instance occupy 24 bytes?
This is where another utility, called `ClassLayout` comes in handy:

<pre class="terminal">
scala&gt; println(ClassLayout.parseClass(classOf[String]).toPrintable)
java.lang.String object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                    VALUE
      0    12        (object header)                N/A
     12     4 char[] String.value                   N/A
     16     4    int String.hash                    N/A
     20     4    int String.hash32                  N/A
Instance size: 24 bytes (estimated, the sample instance is not available)
Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
</pre>

The output says precisely how the object fields will be lay out in the computer
memory and how much space they take up.

The first item, the object header, contains class type information. It starts
at offset 0 and takes up 12 bytes.

The second item is the first object field. In this case we have an array of
chars, which is used to store the actual characters that make up the string.
It starts at offset 12 and occupies 4 bytes. Similar for the subsequent two
fields.

If you'd like to know more, the [project's source tree][1] contains a directory
of samples demonstrating some of its features. It's a good place to learn more
about jol.

## References

 - jol — [https://openjdk.java.net/projects/code-tools/jol/]()
 - [Java Object Layout: A Tale Of Confusion ](http://psy-lob-saw.blogspot.ro/2014/03/java-object-layout-tale-of-confusion.html)
 - [http://bboniao.com/openjdk/2014-06/java-object-layoutjol.html]()

[0]: https://openjdk.java.net/projects/code-tools/jol/
[1]: http://hg.openjdk.java.net/code-tools/jol
