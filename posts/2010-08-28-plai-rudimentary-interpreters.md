--------------------------------------
title: PLAI - Rudimentary Interpreters
author: Ionuț G. Stan
date: August 28, 2010
--------------------------------------

I’ve just finished the second section of
<abbr title="Programming Languages: Application and Interpretation">PLAI</abbr>,
Rudimentary Interpreters.

It revolves around a basic interpreter for arithmetic expressions. The idea was
presented from chapter I actually. The difference is that chapter I introduces
the syntax for this languages, which is more or less Scheme with curly brackets
instead of braces. For example, `{+ 1 2}` represents the addition operation
between the numbers 1 and 2. The second chapter though, deals with the semantics
of the language; introduces concepts such as identifiers, scope and functions.
All in a progressive manner, building new concepts on top of existing ones.

A little digression. PLAI uses a dialect of Scheme as its languages, and while I
like Scheme, this language that they use, called PLAI Scheme, is actually quite
ugly to my eyes. The reason is that it’s some sort of typed Scheme, in that it
has algebraic data types and means of destructuring such data into its variants.
In fact, it looks a lot like Haskell, so what I did was to write all the supporting
code in Haskell. I started with PLAI Scheme in chapter one, but chapter two was
all Haskell. The little disadvantage is that in Haskell I don’t have a `read`
function that takes valid Scheme code and returns a corresponding Scheme data
structure. So I had to write the parser myself, but it was no big deal for two
reasons. First of all, the syntax for this arithmetic language is quite simple,
and secondly, Haskell has really powerful libraries for parsing. For convenience
I’ve used Parsec, as I already have some experience with it, but there lots of
other parsing libraries (I’ve heard some of them are even better than Parsec).
To end this digression, all the Haskell code I wrote for this chapter is available
in my [Github repo][1]. I hope I'll write another blog post with details about
its implementation.

Now, back to the book.

The chapter starts by exploring the concept of identifiers and ways of supporting
them in a language by means of substitution. These identifiers resemble normal
variables that we all know, except for one thing, they can’t be reassigned a new
values. So they’re actually constants, not variables. It then goes on describing
what happens when there are overlapping identifiers names, whether it’s a good
thing and how to implement it correctly. But it’s not a book that gives you the
correct solution from the first shot. It makes you write a program with mistakes,
then provides some examples that won’t work with the respective program, at which
point the whole theory behind the concepts begins. The reason is very simple, the
author wants the readers to judge based on a concrete program instead of some
abstract concepts.

I won’t go into details about substitution, as it is a pretty complex subject and
would provide no information that it’s not in the book. There’s one thing that I
want to mention though. One section of chapter three asks whether names are necessary
for identifiers. It appears that someone called Nicolaas de Bruijn said they’re
not, and instead, he used numbers. This appears to be employed in compiler
construction. Maybe I’ll talk in detail about substitution in a future post.

After substitution, the language is enriched with functions. These are quite
simple conceptually, as they take a single argument and return a value that is
always numeric, but it’s a good start for observing the issues that arise when
combining substitution and functions.

After substitution and functions, the author introduces deferred substitution as
a means of improving the performance of the interpreter. Instead of passing through
the whole program for each identifier that dictates a substitution, the interpreter
is now storing these identifiers and their values in a data structure that is
queried on a per need basis, i.e., whenever a new scope is found that uses a free
identifier.

The last part of this second section of the book deals with first-class functions,
i.e., functions that ca be used as any other value in the language. They can be
returned from functions, or passed to functions. Also, in the moment functions as
first-class values meet deferred substitution, the concept of closure emerges.

In short, that’s what section two of PLAI touches. If you want more details, then
start reading the book. I had a lot of fun implementing this little language in
Haskell. Although small, it encompasses a lot of advanced programming concepts
unavailable in other languages (PHP for example, which is what I do for a living).


[1]: http://github.com/igstan/plai-haskell
