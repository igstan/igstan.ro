--------------------------------------------------------------------------------
title: Notes on SBT
author: Ionuț G. Stan
date: January 05, 2013
--------------------------------------------------------------------------------

An SBT configuration file is a tree of key-value pairs. Key-value is an intentional
simplication, but you don't know that yet. I chose it so that you can gradually
understand what SBT is and does. To recap, a tree of key-value pairs. Almost
like a JSON document.

There are a few operations to manipulate these values:

 - [`:=` literal assignment](#literal-assignment)
 - [`<<=` dependent assignment](#dependent-assignment)
 - [`+=` single append](#single-append)
 - [`++=` sequence append](#sequence-append)
 - [`<+=` dependent sequence append](#dependent-sequence-append)

### Literal Assignment
`:=` literal assignment. Use this to assign a constant value to some configuration
key.

```scala
version := "0.1.0"
```

### Dependent Assignment
`<<=` dependent assignment. Useful when you want to create a value based on
some other values. For example you may want to define the name of the project
as being the previous name concatenated to the Scala version.

```scala
name <<= (Name, scalaVersion)(_ + " for Scala " + _)
```

### Single Append
`+=` append. When you want to add a new value to an existing sequence of values.

```scala
libraryDependencies += "com.example" % "library" % "1.0.0"
```

### Sequence Append
`++` sequence append. When you want to add a *sequence* of values to an existing
sequence of values.

```scala
libraryDependencies ++= Seq(
  "com.example" % "library-a" % "1.0.0",
  "com.example" % "library-b" % "1.0.0"
)
```

### Dependent Sequence Append
`<+=` dependent sequence append. When you want to add a new value to an existing
sequence of values, but the value you want to append depends on the values that
were already defined.



BNF grammar for its DSL.

Looks like functional reactive programming
(<abbr title="Functional Reactive Programming">FRP</abbr>) to me.

## References

 - [Mark Harrah introducing SBT 0.9][0]
 - [SBT and Plugin design][1]

[0]: http://vimeo.com/20263617
[1]: http://suereth.blogspot.com/2011/09/sbt-and-plugin-design.html
