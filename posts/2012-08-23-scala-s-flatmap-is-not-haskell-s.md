--------------------------------------------------------------------------------
title: Scala's flatMap is not Haskell's >>=
author: Ionuț G. Stan
date: August 23, 2012
--------------------------------------------------------------------------------

The behaviour of `flatMap` in Scala:

<pre class="terminal">
scala> List(1, 2, 3, 4) flatMap (Some(_))
res0: List[Int] = List(1, 2, 3, 4)
</pre>

The behaviour of `>>=` in Haskell:

<pre class="terminal">
Prelude> [1, 2, 3, 4] >>= return . Just
[Just 1,Just 2,Just 3,Just 4]
</pre>
