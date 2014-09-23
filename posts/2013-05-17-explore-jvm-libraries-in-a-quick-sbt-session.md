--------------------------------------------------------------------------------
title: Explore JVM Libraries in a Quick sbt Session
author: Ionuț G. Stan
date: May 17, 2013
--------------------------------------------------------------------------------

Dear younger me, here's a quick way to try out a new third-party library in the
Scala REPL without having to create a new sbt project or edit the sbt build file.

In this particular example I'm just playing around with [dispatch][0], trying to
see whether it sends the correct query parameters to [httpbin.org](http://httpbin.org).

### Create Temp Directory
This is an optional step, but I do it because sbt creates two sub-directories:
project and target, and I don't like to pollute whatever directory I'm in (usually
`$HOME` or Desktop).

<pre class="terminal">
λ Desktop master: mkdir -p sbt-project
λ Desktop master: cd sbt-project/
λ sbt-project master: sbt
[info] Set current project to default-a63394 (in build file:/Users/igstan/Desktop/sbt-project/)
</pre>

### Set Scala Version
<pre class="terminal">
> set scalaVersion := "2.10.0"
[info] Defining *:scala-version
[info] The new value will be used by no settings or tasks.
[info] Reapplying settings...
[info] Set current project to default-a63394 (in build file:/Users/igstan/Desktop/sbt-project/)
</pre>

### Add Library as Dependency
<pre class="terminal">
> set libraryDependencies += "net.databinder.dispatch" %% "dispatch-core" % "0.10.0"
[info] Defining *:library-dependencies
[info] The new value will be used by *:all-dependencies
[info] Reapplying settings...
[info] Set current project to default-a63394 (in build file:/Users/igstan/Desktop/sbt-project/)
</pre>

### Enter the REPL
<pre class="terminal">
> console
[info] Updating {file:/Users/igstan/Desktop/sbt-project/}default-a63394...
[info] Resolving org.slf4j#slf4j-api;1.6.2 ...
[info] Done updating.
[info] Starting scala interpreter...
[info]
Welcome to Scala version 2.10.0 (Java HotSpot(TM) 64-Bit Server VM, Java 1.7.0_21).
Type in expressions to have them evaluated.
Type :help for more information.
</pre>

### Import Dependencies
<pre class="terminal">
scala> import dispatch._, Defaults._
import dispatch._
import Defaults._
</pre>

### Create a Request Builder
<pre class="terminal">
scala> val u = url("http://httpbin.org/get")
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
u: com.ning.http.client.RequestBuilder = com.ning.http.client.RequestBuilder@2cce6b12
</pre>

### Add Some Query Params
<pre class="terminal">
scala> u &lt;&lt;? Seq("a" -> "foo", "b" -> "bar")
res0: com.ning.http.client.RequestBuilder = com.ning.http.client.RequestBuilder@2cce6b12
</pre>

### Execute Request
<pre class="terminal">
scala> val r = Http(u.OK(as.String))
r: dispatch.Future[String] = scala.concurrent.impl.Promise$DefaultPromise@7495a73e
</pre>

<pre class="terminal">
scala> r.onComplete(println(_))

scala> Success({
  "args": {
    "a": "foo",
    "b": "bar"
  },
  "headers": {
    "Connection": "close",
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "Dispatch/0.10.0"
  },
  "url": "http://httpbin.org/get?q=foo"
})

scala>
</pre>

## Improvements
I've added a bash alias that saves me from creating a scratch directory
every time I'd like to play with some library:

~~~bash
take () {
  mkdir -p $1 &&
  cd $1
}

alias sbt-playground="take '$HOME/.sbt-playground' && sbt"
~~~

Also, because the command to add a library dependency is quite long, I've created
an sbt alias in `$HOME/.sbtrc`:

~~~
alias dep=set libraryDependencies +=
~~~

Now, all I have to type in the sbt console is this command:

<pre class="terminal">
> dep "net.databinder.dispatch" %% "dispatch-core" % "0.10.0"
</pre>



[0]: http://dispatch.databinder.net/Dispatch.html
