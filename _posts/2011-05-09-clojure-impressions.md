---
title: Clojure Impressions
author: Ionuț G. Stan
date: May 09, 2011
---

Following some unintentional peer pressure on Twitter, with people acclaiming
the recently published book "Joy of Clojure", and some others showing their
solutions to the Clojure problems on [4clojure.com][1], I finally decided
to try this language a bit. I've refrained myself from doing so for almost a year
and a half. The main reason was that it didn't seem to be as elegant as Scheme.
There's something about the look of Clojure programs that reminds me of dirt. I
can't really put my finger on it, but that's what I feel sometimes. A second
reason was the JVM. Just as with many other people, for some time I thought JVM
and Java are the same thing. Now I don't, but I still dislike the time it takes
JVM to start up.

The way I approached Clojure was by trying to solve the problems on [4clojure.com][1].
I didn't read any tutorial beforehand though. I'm familiar with Scheme, and
lately I've been writing some Haskell code too. So, both the basics of the syntax
and the paradigm (functional programming with laziness) were there. However,
throughout the whole exercise I made good use of the reference on [clojuredocs.org][2].

Below I'd like to capture my current impression about this language, while it's
still fresh in my mind.


Syntax
------
I like the syntax. Well, not all of it, but the basic syntax because it's Lisp.
And, it may seem strange, but sometimes I kind of wish Clojure made use of more
(round) parentheses. I don't particularly like the square brackets of `let` or
the `:else` keyword of `cond`, but I got used to the square brackets of `defn`.
The syntax for calling into Java is also kind of weird.


Strings and Characters
----------------------
This was my first WTF with Clojure. Mainly because now I expect every respectable
programming language to treat strings the way Haskell does, i.e. as a list of
characters. I quickly found out that strings in Clojure are... Java strings. Well,
to be honest, I don't fucking care what language they used to implement Clojure.
And the fact that they let this thing leak through didn't look good to me. This
is actually a bigger problem with Clojure. It leaks implementation details in
multiple places. If you want to manipulate strings or characters, you have to
resort to the Java API for strings and characters. If you've got an exception in
your program, well... you have to wade through the guts of the Clojure's internals
stack trace in order to find the line number you're interested in. And that's when
that number exists, because sometimes it's just 0.

I know that strings are actually transformed to sequences in most of the core
functions, but you still have to jump some hoops. Here's what I mean. Let's
upper-case a string, shall we? The obvious answer would be:

<pre class="terminal">user=> (.toUpperCase "foo")
"FOO"
</pre>

And it could be fine, but... ah, why do I have to call a Java method?

Now, let's pretend I don't know there's a `.toUpperCase` method on `String`, but
I know there's one such static method on the `Character` class.

<pre class="terminal">user=> (map Character/toUpperCase "foo")
java.lang.Exception: Unable to find static field: toUpperCase in class ...
</pre>

Oh, Java methods aren't really first class functions. We're talking about Java
so we shouldn't be surprised. Next try.

<pre class="terminal">user=> (map #(Character/toUpperCase %) "foo")
(\F \O \O)
</pre>

Huh? Where's my string? Next try.

<pre class="terminal">user=> (str (map #(Character/toUpperCase %) "foo"))
"clojure.lang.LazySeq@18505"
</pre>

Lazy? Why? Next try.

<pre class="terminal">user=> (apply str (map #(Character/toUpperCase %) "foo"))
"FOO"
</pre>

That's better, but too much for something that could just as well be:

<pre class="terminal">user=> (map upper-case "foo")
"FOO"
</pre>

So, in short, I don't like that strings and characters are not citizens of
Clojure, but rather visitors from the land of Java.


Documentation
-------------
Every function in Clojure's core is documented. It uses the same convention that
Python uses. A multiline string at the beginning of the function represents the
documentation. Not unexpectedly, there's a `doc` function available inside the
REPL that takes a function value (not function name) and returns its docs. Pretty
much like Python's `help` function. However there's more in Clojure. You have
access to every core function's source code by calling the `source` function.
This is hugely useful because, as we all know, docs aren't perfect, so it helps
to sometimes take a look at the source of the function and try to understand what
that docstring is actually trying to say. There's also `find-doc` and `javadoc`.
I really like this part of Clojure.


Standard Library
----------------
There's a plethora of functions in clojure.core. Most of them being there to
support the ubiquitous sequences of Clojure. If you're used to Haskell, it may
look like there's something in Haskell and not in Clojure. It may be true, but
you should first ask around because it might be there under a different name.
For example I found myself wanting a `zipWith` function:

<pre class="terminal">Prelude> zipWith (+) [1,2,3] [4,5,6]
[5,7,9]
</pre>

I couldn't find it in the beginning. Later on I discovered that Clojure's `map`
function actually maps over multiple collections. So there it was, my `zipWith`
function in disguise.

<pre class="terminal">user=> (map + [1 2 3] [4 5 6])
(5 7 9)
</pre>

Actually, it's more than `zipWith`, because Clojure is dynamic and takes an
infinite number of collections to iterate over, while `zipWith` takes just two.
You'd need `zipWith3` for three collections, `zipWith4` for four collections, and
so on up to seven. Also, the equivalent for Haskell's `zip` is `zipmap`.


Polymorphism of `conj`
----------------------
I don't think I have yet started to love this. `conj` seems too polymorphic for
my taste. It may either prepend an element if the collection is a list, or append
it, if the collection is a vector. Not to mention it also works on maps and sets.

I did't like `conj` especially when I had to work with functions generating lazy
sequences. Whenever I saw `conj` I had to read carefully to see what kind of
collection that `conj` acts on. Most of the time they're lists, but sometimes
it's a vector and you end up with a reversed list without knowing why.

`conj` is useful, but I think it should be used with care.


Laziness
--------
It was a nice pleasure to see Clojure having support for laziness. There are
plenty of algorithms on sequences that are easier to implement when you have
lazy sequences.

In Clojure, laziness is something you opt in when you're writing your function
by constructing sequences with `lazy-seq`. However, because there are so many
built-in functions that return lazy sequences most of the time you won't feel
a difference compared to Haskell.


Pattern Matching
----------------
Another nice surprise. I didn't use it too much because I'm not used to pattern
matching in a Lisp, but it's powerful and can make the code both more concise
and readable.


Tail-Call Recursion
-------------------
Just as with laziness, you have to explicitly opt-in for tail-call recursion.
It's the same thing as in any other language that supports tail-calls, you have
to make sure that the recursive call is the last thing that your function does.
However, in Clojure, you have to use the `recur` special form instead of the
function name. That signals the Clojure compiler that you want tail-call
recursion.

~~~clojure
(defn gcd [a b]
  "Calculates greatest common divisor using Euclid's algorithm."
  (if (zero? b) a
      ;; uses `recur` instead of `gcd`
      (recur b (mod a b))))
~~~


Java Interoperability
---------------------
This one is what made Clojure popular. And it appeals to me too, even if I'm not
a Java person. In the past I had to use some Java libraries, like Apache POI for
processing Excel files, and back then I scripted them using JavaScript (with
Mozilla Rhino). Nowadays, if I were to solve the same problem, I'd probably
choose Clojure. Once you hide the Java ugliness behind a sane, Lisp-like, API,
things are much better.

But this is something that I also fear. It may happen that some of the monstrosity
of Java libraries will percolate through all these layers of abstraction until
it hits Clojure. I don't know, maybe it won't happen, but I still think it would
be a pity.


`seq?` vs `sequential?`
-----------------------
This is something I haven't yet understand despite my attempts. I have googled
the topic and even looked inside the Clojure source code. The two are still
foggy subjects in my mind. Mainly because of those leaks I was talking above.
For example the docs for `sequential?` read:

> Returns true if coll implements Sequential

Ok, and what exactly that means? I took a look at the Sequential interface, and
to my surprise it was used as a marker interface, i.e. it specifies no methods.
It is used in several places with `instanceof` checks. Until now, it seems that
`sequential?` will tell you if the order of the elements in a collection matters.
For example it returns `true` for both lists and vector, but not for maps and
sets.

The docs for `seq?` read:

> Return true if x implements ISeq

Please, not Java interfaces again... Fortunately this time `ISeq` is not a marker
interface, but I shouldn't have to read the internals of Clojure to figure out
what this function does. Anyway, this function answers whether the passed argument
is a data structure that supports three main operations on it:

 - first
 - rest
 - cons


Gotchas
-------
Just one for the moment. `contains?` works on keys not on values, but beware,
sets are like a collection of keys, so:

<pre class="terminal">user=> (contains?  [1 2 3] 3)
false
user=> (contains? #{1 2 3} 3)
true
</pre>


The End
-------
These are my first impressions with Clojure. I had a great time solving those
problems on [4clojure.com][1] and I think you'll enjoy them too. Thus far I like
Clojure.

[1]: http://4clojure.com
[2]: http://clojuredocs.org
