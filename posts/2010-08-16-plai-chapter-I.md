-----------------------
title: PLAI - Chapter I
author: Ionuț G. Stan
date: August 16, 2010
-----------------------


Yesterday I've begun reading [Programming Languages: Application and Interpretation][1]
(abbreviated <abbr title="Programming Languages: Application and Interpretation">PLAI</abbr>),
written by Shriram Krishnamurthi. The book is available for free in PDF format.

The main reason for starting it is because I've noticed, about a year ago, that
I have a passion for programming languages. I like to learn new programming languages,
programming concepts or ways to make such languages more expressive. The final
goal would be to implement myself a programming language. This goal, however, is
not set for the near future. First of all, I want to work hard in the trenches
with multiple languages, and learn as much as I can about languages that have
gone away, or maybe that have influenced other ones. In order to invent, I need
an inventory.

For the next month or so, I plan to read the above book. It is used as a text
book at Brown University, and seemingly in some other universities. The thing
that got me about it is the titles of the chapters. I've heard about most of
those concepts in my short experience with several languages, and maybe even
worked with several of them, but I certainly want to know more about them (like
ways of implementing them, advantages and disadvantages). Things like laziness,
recursion, (immutable) state, continuations, type inference and metaprogramming
are guaranteed to give me thrills at this point in my life. They may sound like
buzzwords, and they may actually be in this moment of functional programming
resurrection, but... as I have little knowledge about them (that means, I can't
yet explain them that well to you, I only have instinctive understanding) it
seems normal to attract me so much.

Yesterday I've read the first chapter, the Prelude, which is basically an
introduction to programming language modelling and some theory about parsers.

The main thing that should be retained from this chapter would be that each
programming language (I'd say programming platform though, because of the
libraries part) consists of four categories:

 - syntax
 - behavior associated with syntax: semantics
 - libraries
 - idioms

Also, as a note for those interested in reading the book themselves. I'm using
[DrRacket][2] to work through the examples, but the syntax isn't standard Scheme,
so I had to choose the "Pretty Big" language.

Now, I'm going to start reading the next chapter: Rudimentary Interpreters.


[1]: http://www.cs.brown.edu/~sk/Publications/Books/ProgLangs/
[2]: http://racket-lang.org/
