---
title: Scala's flatMap is not Haskell's >>=
author: Ionuț G. Stan
date: August 23, 2012
---

The behaviour of `flatMap` in Scala:

<pre class="terminal">
scala> List(1, 2, 3, 4) flatMap (Some(_))
res0: List[Int] = List(1, 2, 3, 4)
</pre>

The behaviour of `>>=` in Haskell:

<pre class="terminal">
> [1, 2, 3, 4] >>= Just

&lt;interactive&gt;:4:18:
    Couldn't match expected type `[b0]' with actual type `Maybe a0'
    Expected type: a0 -> [b0]
      Actual type: a0 -> Maybe a0
    In the second argument of `(>>=)', namely `Just'
    In the expression: [1, 2, 3, 4] >>= Just
</pre>
