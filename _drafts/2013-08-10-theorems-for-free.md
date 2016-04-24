--------------------------------------------------------------------------------
title: Theorems For Free
author: Ionuț G. Stan
date: August 10, 2013
--------------------------------------------------------------------------------

Anecdote: I set out to write this blog post using Scala, but I quickly realized
that it would be a bad choice, so I resorted to Haskell in the end.

~~~haskell
import Data.Char (toUpper)

r :: [a] -> [a]
r = undefined

mapA :: [Char] -> [Char]
mapA = map toUpper

rThenMap = mapA . r
mapThenR = r . mapA
-- rThenMap and mapThenR are equivalent
~~~





Papers in References:

 - Derivation of a pattern-matching compiler.
 - Categories for the working hardware designer.

Girard/Reynolds type system, aka polymorphic lambda calculus, second order lambda
calculus, or System F.




~~~scala
def r[X](xs: List[X]): List[X]

type R[A] = (as: List[A]) => List[A]

def r1: R[String] = ???
def r2: R[Int] = ???

(map _).compose(r1) == r2.compose(map _)
~~~
