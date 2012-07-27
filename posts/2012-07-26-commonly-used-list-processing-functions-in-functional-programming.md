--------------------------------------------------------------------------------
title: Commonly Used List Processing Functions in FP
author: Ionuț G. Stan
date: July 26, 2012
--------------------------------------------------------------------------------

A list of commonly used functions for processing collections in
<abbr title="Functional Programming">FP</abbr> languages or when adopting an
<abbr title="Functional Programming">FP</abbr> style. Grouped by language in
alphabetical order. The listing order for the functions is the same for every
language. Some functions, though, are missing in some languages or there are
alternative ways to accomplish the same goal.

 - [Clojure](#clojure)
 - [Erlang](#erlang)
 - [Haskell](#haskell)
 - [JavaScript](#javascript-using-underscore.js)
 - [Scala](#scala)

Clojure
-------
 - [`first`](http://clojuredocs.org/clojure_core/clojure.core/first)
 - [`rest`](http://clojuredocs.org/clojure_core/clojure.core/rest)
 - [`map`](http://clojuredocs.org/clojure_core/clojure.core/map)
 - [`filter`](http://clojuredocs.org/clojure_core/clojure.core/filter) or its
   dual [`remove`](http://clojuredocs.org/clojure_core/clojure.core/remove)
 - [`every?`](http://clojuredocs.org/clojure_core/clojure.core/every_q) or its
   dual [`not-every?`](http://clojuredocs.org/clojure_core/clojure.core/not-every_q)
 - [`some`](http://clojuredocs.org/clojure_core/clojure.core/some) or its
   dual [`not-any?`](http://clojuredocs.org/clojure_core/clojure.core/not-any_q)
 - [`zipmap`](http://clojuredocs.org/clojure_core/clojure.core/zipmap)
 - `zip-with`. There's no such function in Clojure, but the same thing can be
   achieved by passing at least two collections to [`map`](http://clojuredocs.org/clojure_core/clojure.core/map).
 - [`take`](http://clojuredocs.org/clojure_core/clojure.core/take)
 - [`take-while`](http://clojuredocs.org/clojure_core/clojure.core/take-while)
 - [`drop`](http://clojuredocs.org/clojure_core/clojure.core/drop)
 - [`drop-while`](http://clojuredocs.org/clojure_core/clojure.core/drop-while)
 - [`reduce`](http://clojuredocs.org/clojure_core/clojure.core/reduce)

Please note that some of the functions above will probably be superseded by the
new [reducers library](http://clojure.com/blog/2012/05/15/anatomy-of-reducer.html).


Erlang
------
 - [`hd/1`](http://www.erlang.org/doc/man/erlang.html#hd-1)
 - [`tl/1`](http://www.erlang.org/doc/man/erlang.html#tl-1)
 - [`lists:map/2`](http://www.erlang.org/doc/man/lists.html#map-2)
 - [`lists:filter/2`](http://www.erlang.org/doc/man/lists.html#filter-2)
 - [`lists:all/2`](http://www.erlang.org/doc/man/lists.html#all-2)
 - [`lists:any/2`](http://www.erlang.org/doc/man/lists.html#any-2)
 - [`lists:zip2/2`](http://www.erlang.org/doc/man/lists.html#zip-2) and
   [`lists:zip3/3`](http://www.erlang.org/doc/man/lists.html#zip-2)
 - [`lists:takewhile/2`](http://www.erlang.org/doc/man/lists.html#takewhile-2)
 - [`lists:dropwhile/2`](http://www.erlang.org/doc/man/lists.html#dropwhile-2)
 - [`lists:foldl/3`](http://www.erlang.org/doc/man/lists.html#foldl-3)
 - [`lists:foldr/3`](http://www.erlang.org/doc/man/lists.html#foldr-3)

Haskell
-------
 - [`head`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:head)
 - [`tail`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:tail)
 - [`map`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:map)
 - [`filter`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:filter)
 - [`all`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:all)
   or the closely related [`and`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:and)
 - [`any`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:any)
   or the closely related [`or`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:or)
 - [`zip`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:zip)
   or any of the `zip3` up to `zip7` in the
   [`Data.List` module](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Data-List.html#v:zip3)
 - [`zipWith`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:zipWith)
   or any of the `zipWith3` up to `zipWith7` in the
   [`Data.List` module](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Data-List.html#v:zipWith3)
 - [`take`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:take)
 - [`drop`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:drop)
 - [`takeWhile`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:takeWhile)
 - [`dropWhile`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:dropWhile)
 - [`foldl`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:foldl)
 - [`foldr`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:foldr)

JavaScript (using underscore.js)
--------------------------------
 - [`first`](http://underscorejs.org/#first)
 - [`rest`](http://underscorejs.org/#rest)
 - [`map`](http://underscorejs.org/#map)
 - [`filter`](http://underscorejs.org/#filter) and its dual [`reject`](http://underscorejs.org/#reject)
 - [`all`](http://underscorejs.org/#all)
 - [`any`](http://underscorejs.org/#any)
 - [`zip`](http://underscorejs.org/#zip3)
 - [`reduce` / `inject` / `foldl`](http://underscorejs.org/#reduce)
 - [`reduceRight` / `foldr`](http://underscorejs.org/#reduceRight)

Scala
-----
 - [`head`](http://scalex.org/?q=List.head#scalacollectionimmutableListAheadA)
 - [`tail`](http://scalex.org/?q=List.tail#scalacollectionimmutableListAtailListA)
 - [`map`](http://scalex.org/?q=List.map#scalacollectionimmutableListAmapBfABListB)
 - [`filter`](http://scalex.org/?q=List.filter#scalacollectionimmutableListAfilterpABooleanListA)
   and its dual [`filterNot`](http://scalex.org/?q=List.filter#scalacollectionimmutableListAfilterNotpABooleanListA)
 - [`forall`](http://scalex.org/?q=List.forall#scalacollectionimmutableListAforallpABooleanBoolean)
 - [`exists`](http://scalex.org/?q=List.forall#scalacollectionimmutableListAexistspABooleanBoolean)
 - [`zip`](http://scalex.org/?q=List.forall#scalacollectionimmutableListAzipBthatGenIterableBListAB)
 - `zipWith`. There's no such method in Scala, instead use the
   [`zipped`](http://scalex.org/?q=Tuple2.zipped#scalaTuple2T1T2zippedRepr1El1Repr2El2implicitw1T1TraversableLikeEl1Repr1implicitw2T2IterableLikeEl2Repr2ZippedRepr1El1Repr2El2)
   method which is only available for
   [`Tuple2`](http://www.scala-lang.org/api/current/scala/Tuple2#!%3D%28Any%29%3ABoolean)
   and
   [`Tuple3`](http://www.scala-lang.org/api/current/scala/Tuple3#!%3D%28Any%29%3ABoolean)
 - [`take`](http://scalex.org/?q=List.zipWith#scalacollectionimmutableListAtakenIntListA)
 - [`drop`](http://scalex.org/?q=List.drop#scalacollectionimmutableListAdropnIntListA)
 - [`takeWhile`](http://scalex.org/?q=List.zipWith#scalacollectionimmutableListAtakeWhilepABooleanListA)
 - [`dropWhile`](http://scalex.org/?q=List.dropWhile#scalacollectionimmutableListAdropWhilepABooleanListA)
 - [`foldLeft`](http://scalex.org/?q=List.reduceLeft#scalacollectionimmutableListAfoldLeftBzBfBABB)
 - [`reduceLeft`](http://scalex.org/?q=List.reduceLeft#scalacollectionimmutableListAreduceLeftBAfBABB)
 - [`foldRight`](http://scalex.org/?q=List.foldRight#scalacollectionimmutableListAfoldRightBzBfABBB)
