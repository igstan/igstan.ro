Functional IO

I've got a few issues remaining in order to completely understand functional IO.
I'm fairly sure I understand the gist of it, but there's a missing part to
complete the picture. As I've already discussed on Twitter with Tony Morris[0],
I see functional IO as a means of building, in a host language like Scala, the
AST of an imperative language which does IO. IO would then be an embedded domain
specific language. This blog post describes it better though [1].

It seems *to me* that the idea of this solution is that all the actual
IO stuff is deferred as much as possible, basically until the interpreter of
that IO monad evaluates the IO expression. Normally, that IO interpreter is a
primitive one, in other words it's the interpreter of the host language, and
can't be built into into the host language of the IO monad.

And this is were my understanding troubles start. It seems that the impure part
of a functional IO system is not the language, but the interpreter. So... couldn't
we say that Java the language is a pure language, while the JVM is impure? What
are the actual semantics that define purely functional IO? Is it the laziness
part? Maybe it's actually the interleaving of IO and pure AST interpretation.
What I mean by that is that in a purely functional IO system the AST must be
fully reduced to a single expression before *any* IO is performed, whereas in
an impure one, IO may be performed during the AST traversal and reduction.



[0]: https://twitter.com/igstan/status/355313680134582272
[1]: http://chris-taylor.github.io/blog/2013/02/09/io-is-not-a-side-effect/
