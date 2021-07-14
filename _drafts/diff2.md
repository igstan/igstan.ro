---
title: "Paper: An O(ND) Difference Algorithm"
author: Ionuț G. Stan
date: January 03, 2015
---

I've been working on a personal project in the days around Christmas and New
Year's celebrations and at the bottom of a very deep [yak-shaving][0] tree of
problems I had to solve was how to show the difference between two strings.

This is pretty much a solved problem now, so I could have resorted to an
existing library. Nevertheless, because I'm using Standard ML for this
particular project, I couldn't readily find such a diff library. Additionally,
being a side-project, I thought it would be a good time to learn something new.
This is why I started researching for string differentiation algorithms in
existing literature in order to implement them.

During my searches, one algorithm was mentioned over and over again, one which
is purportedly used by both Git and SVN. The algorithm is credited to Eugene W.
Myers and was published in a 1986 paper called ["An O(ND) Difference Algorithm
and Its Variations"][1].

Without much further thought, I started reading the paper. Three passes later
and the explanations in the paper were still not very clear to me. I've looked
for blog posts investigating the algorithm and giving alternative explanations.
I [found one][2] eventually, but I wasn't satisfied with it. In the end I
decided to make as many passes as necessary over the paper, fully understand the
algorithm and publish a blog post where I analyze the paper in detail. This is
that blog post.

As a side note, the paper is pretty self-contained, in that it doesn't require
reading any of the references at the end in order to have a chance at
understanding what the author is talking about.

## 1. Structure

In the following, I will first review and explain as well as I can all the
[concepts](#concepts) presented in the paper that are necessary to understand
two important observations about the problem. Next, I will describe the two
[observations](#observations) made by Myers and how they help with the problem.
Subsequently, I will show [the algorithm](#the-algorithm) devised by Myers and
then go over it and explain how each statement or expression relates to the
concepts listed in the first section. Finally, in the fifth section, I will
present [a refinement](#a-refinement) of the algorithm which will require only
liniar space to run.

  2. [Concepts](#concepts)
    1. [Edit Graph](#edit-graph)
    2. [Edit Script](#edit-script)
    3. [Match Points and Diagonal Edges](#match-points-and-diagonal-edges)
    4. [D-paths and Snakes](#d-paths-and-snakes)
  3. [Observations](#observations)
    1. [Lemma 1](#lemma-1)
    2. [Lemma 2](#lemma-2)
  4. [The Algorithm](#the-algorithm)
  5. [A Refinement](#a-refinement)

## 1. The Problem

First things first, what problem does this paper try to solve? Briefly, it tries
to find a (more efficient) method for finding the shortest sequence of delete/insert
commands that will transform an <dfn>original</dfn> sequence A into a <dfn>modified</dfn>
sequence B. This sequence is the encoding of the differences between **A** and
**B**.

In the paper, as well as this blog post, the running example uses **A** = _abcabba_
and **B** = _cbabac_, for which a sequence of commands might look like this:

 - **delete** 1st character of **A**: <del>a</del>bcabba
 - **delete** 2nd character of **A**: <del>b</del>cabba
 - **insert** character _b_ after the 3rd character of **A**: c<ins>b</ins>abba
 - **delete** 6th character of **A**: cbab<del>b</del>a
 - **insert** character _c_ after the 7th character of **A**: cbaba<ins>c</ins>

Putting all these operations together will yield the following, perhaps more
familiar, diff format: <del>ab</del>c<ins>b</ins>ab<del>b</del>a<ins>c</ins>.

Note that conceptually all the operations are performed in parallel, which means
that the indeces used as arguments are all relative to the original, unmodified
sequence **A**. Also, the shown sequence is not necessarily the only possible
sequence, there may be many of them, but we want to find the shortest one.

It turns out that this problem is the exact opposite of finding the longest
common _subsequence_ (<abbr title="Longest Common Subsequence">LCS</abbr>)
of two strings. Pay attention to the difference, it's **subsequence**, not
substring. The latter requires a **contiguous** succession of characters, while
the former does not. For example, the longest common subsequence for our **A**
and **B** is _caba_.

<pre><code>ab<b>cab</b>b<b>a</b>
<b>c</b>b<b>aba</b>c
</code></pre>

All the characters in **A** that are not part of the <abbr title="Longest Common Subsequence">LCS</abbr>
will apear in delete commands, while all the characters in **B** not part of the
<abbr title="Longest Common Subsequence">LCS</abbr> will appear in insert commands.

## 2. Concepts

The second section of the original paper introduces a series of concepts related
to the problem of finding a longest common subsequence. Below, I will try to
explain and/or give alternative descriptions to those found in the paper. In
addition, I will use more images than the paper to depict concrete examples of
the concepts discussed, as this has proved crucial while I studied the paper
myself.

 - [Edit Graph](#edit-graph)
 - [Edit Script](#edit-script)
 - [Match Points and Diagonal Edges](#match-points-and-diagonal-edges)
 - [Edit Graph Diagonals](#edit-graph-diagonals)
 - [D-paths and Snakes](#d-paths-and-snakes)

### Edit Graph

We can graphically represent all the possible ways of converting **A** into **B**
by drawing a grid where columns are generated by characters in **A** and rows
by characters in **B**.

<div class="image">
  <img src="/files/images/edit-graph.png" alt="Edit Graph">
</div>

This grid can be seen as a graph, where the intersection points represent
vertices which divide each corresponding line into graph edges.

This graph is called an <dfn>edit graph</dfn> because by giving special meaning
to the two kinds of edges — horizontal and vertical — we can obtain paths that
edit, or transform, the original sequence into the modified one.

### Edit Script

In the scheme presented in the paper, where the original sequence is placed
horizontally, horizontal edges mean **delete** and vertical edges mean **insert**.

Take for example the following path:

<div class="image">
  <img src="/files/images/edit-path-example-01.png" alt="Edit Path, Example 1">
</div>

The meaning of the above path translates into the following series of insert and
delete commands:

 - `delete(x = 1)`
 - `delete(x = 2)`
 - `delete(x = 3)`
 - `delete(x = 4)`
 - `delete(x = 5)`
 - `delete(x = 6)`
 - `delete(x = 7)`
 - `insert(x = 7, char = C)`
 - `insert(x = 7, char = B)`
 - `insert(x = 7, char = A)`
 - `insert(x = 7, char = B)`
 - `insert(x = 7, char = A)`
 - `insert(x = 7, char = C)`

Where `delete(x = i)` means "delete the <var>i</var>-th character in **A**" and
`insert(x = i, char = c)` means "insert character <var>c</var> after the
<var>i</var>-th character in **A**".

Similarly, the path in the image below...

<div class="image">
  <img src="/files/images/edit-path-example-02.png" alt="Edit Path, Example 2">
</div>

...would be translated to this sequence of commands:

 - `delete(x = 1)`
 - `insert(x = 1, char = C)`
 - `delete(x = 2)`
 - `insert(x = 2, char = B)`
 - `delete(x = 3)`
 - `insert(x = 3, char = A)`
 - `delete(x = 4)`
 - `insert(x = 4, char = B)`
 - `delete(x = 5)`
 - `insert(x = 5, char = A)`
 - `delete(x = 6)`
 - `insert(x = 6, char = C)`
 - `delete(x = 7)`

### Match Points and Diagonal Edges

Have you noticed something peculiar about the preceding series of commands? We
have pairs of subsequent operations that cancel each other. For example, we
delete a character just to insert it back again in the subsequent command:

 - `delete(x = 2)`
 - `insert(x = 2, char = B)`

This happens for those vertices in the graph located at the intersection of
lines generated by equal characters. These vertices are called <dfn>match
points</dfn>. Below, they're represented by green circles.

<div class="image">
  <img src="/files/images/match-points.png" alt="Edit Graph with Match Points">
</div>

For clarity, here's the graphical representation for the operations that cancel
each other.

<div class="image">
  <p>Delete B</p>
  <img src="/files/images/edit-paths-delete-B.png" alt="Edit Path: Delete B">
</div>

<div class="image">
  <p>Insert B</p>
  <img src="/files/images/edit-paths-insert-B.png" alt="Edit Path: Insert B">
</div>

<div class="image">
  <p>Insert A</p>
  <img src="/files/images/edit-paths-insert-A.png" alt="Edit Path: Insert A">
</div>

<div class="image">
  <p>Delete A</p>
  <img src="/files/images/edit-paths-delete-A.png" alt="Edit Path: Delete A">
</div>

<div class="image">
  <p>Insert 2nd B</p>
  <img src="/files/images/edit-paths-insert-second-B.png" alt="Edit Path: Insert 2nd B">
</div>

<div class="image">
  <p>Delete 2nd B</p>
  <img src="/files/images/edit-paths-delete-second-B.png" alt="Edit Path: Delete 2nd B">
</div>

This is where <dfn>diagonal edges</dfn> come into play. Informally, these can be
considered contractions of pairs of edges that cancel each other, like the ones
we've just seen; shortcuts. They only exist where a character from **A** matches
one from **B**.

<div class="image">
  <p>Diagonal Edges</p>
  <img src="/files/images/diagonal-edges.png" alt="Edit Graph with Diagonal Edges">
</div>

### Edit Graph Diagonals

<div class="image">
  <p>Edit Graph with Diagonals</p>
  <img src="/files/images/diagonals.png" alt="Edit Graph with Diagonals">
</div>

### D-paths and Snakes

A <dfn>D-Path</dfn> is a path starting from the `(0,0)` vertex which contains
<var>D</var> non-diagonal paths. Here are a few examples:

<div class="image">
  <p>A 2-path, ending on diagonal 0</p>
  <img src="/files/images/2-path-version-a.png" alt="2-path, Version A">
</div>

<div class="image">
  <p>Another 2-path, ending on diagonal 0</p>
  <img src="/files/images/2-path-version-b.png" alt="2-path, Version B">
</div>

Note that a D-path need not traverse the whole edit graph.

Note that there may be many D-paths for a particular value of D (5 in the
example above). They may end on different k-diagonals.

A D-path that ends on a vertex with coordinates greater than any other similar
D-path is called <dfn>furthest reaching</dfn>.

A furthest reaching D-path tries to find the path that takes us closer to the
final answer in the smallest number of steps.

<div class="image">
  <p>A furthest reaching 2-path, ending on diagonal 0.</p>
  <img src="/files/images/2-path-version-c.png" alt="2-path, Version C">
</div>

<div class="image">
  <p>Another furthest reaching 2-path, ending on diagonal 0.</p>
  <img src="/files/images/2-path-version-d.png" alt="2-path, Version D">
</div>

Informally, a D-path tries to find the path that terminates with the longest
sequence of diagonal edges on the respective k-diagonal. This ending path of
a D-path, composed only of diagonal edges is called a <dfn>snake</dfn>. Any
horizontal or vertical edge that follows the snake of such a D-path will be
part of a (D + 1)-path.

The diagonals are used as virtual railways in the algorithm to search for a
solution further and further away from the origin.

## 3. Observations

### Lemma 1

> A D-path must end on diagonal k ∈ { -D, -D + 2, ... , D - 2, D }.

### Lemma 2

> A furthest reaching 0-path ends at (x,x), where x is min(z−1 || az ≠ bz or z > M
> or z > N). A furthest reaching D-path on diagonal k can without loss of
> generality be decomposed into a furthest reaching (D − 1)-path on diagonal k −
> 1, followed by a horizontal edge, followed by the longest possible snake or it
> may be decomposed into a furthest reaching (D − 1)-path on diagonal k + 1,
> followed by a vertical edge, followed by the longest possible snake.

## 4. The Algorithm

<pre><code><b>Constant</b> MAX ∈ [0, M + N]

<b>Var</b> V: <b>Array</b>[-MAX .. MAX] <b>of Integer</b>

V[1] ← 0

<b>For</b> D ← 0 <b>to</b> MAX <b>Do</b>
  <b>For</b> k ← -D <b>to</b> D <b>in steps of</b> 2 <b>Do</b>
    <b>If</b> k = -D <b>or</b> k ≠ D <b>and</b> V[k - 1] &lt; V[k + 1] <b>Then</b>
      x ← V[k + 1]
    <b>Else</b>
      x ← V[k - 1] + 1

    y ← x - k

    <b>While</b> x &lt; N <b>and</b> y &lt; M <b>and</b> a<sub>x + 1</sub> = b<sub>y + 1</sub> <b>Do</b>
      (x, y) ← (x + 1, y + 1)

    V[k] ← x

    <b>If</b> x ≥ N <b>and</b> y ≥ M <b>Then</b>
      <i>Length of an SES is D</i>
      <b>Stop</b>

<i>Length of an SES is greater than MAX</i></code></pre>

## 5. A Refinement

[0]: http://www.hanselman.com/blog/YakShavingDefinedIllGetThatDoneAsSoonAsIShaveThisYak.aspx
[1]: http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.4.6927
[2]: http://www.codeproject.com/articles/42279/investigating-myers-diff-algorithm
[3]: https://github.com/tonyg/rmacs/blob/17f3babfd02145ec21a40b98749f0d03297af5e7/rmacs/diff.rkt
[4]: http://www.ics.uci.edu/~eppstein/161/960229.html
[5]: https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/
