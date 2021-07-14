---
title: Scala's Virtualized Pattern Matching
author: Ionuț G. Stan
---

```scala
//
// $ scala -Yvirtpatmat
//
object main {
  object __match {
    def zero = {
      println("zero"); None
    }

    def one[T](x: T) = {
      println("one"); Some(x)
    }

    // NOTE: guard's return type must be of the shape M[T], where M is the monad
    // in which the pattern match should be interpreted
    def guard[T](cond: Boolean, thenn: => T): Option[T] = {
      println("guard");
      if (cond) Some(thenn) else None
    }

    def runOrElse[T, U](x: T)(f: T => Option[U]): U = {
      println("runOrElse");
      f(x) getOrElse (throw new MatchError(x))
    }

    // def isSuccess[T, U](x: Rep[T])(f: Rep[T] => M[U]): Rep[Boolean] // used for isDefinedAt
  }

  object patmat {
    def main(args: Array[String]): Unit = {
      val c = (1, 2) match {
        case (a, b) if a == b => a + b
      }

      println(s"c: $c")
    }
  }
}
```
