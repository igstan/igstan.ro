------------------------------------------------------
title: My first contribution to an open source project
author: Ionuț G. Stan
date: January 05, 2009
------------------------------------------------------


Two weeks ago, while writing some unit tests for one of my projects I wanted to
use an [XML configuration file][1] in order to bootstrap the [PHPUnit testing
framework][2]. As you may know, in PHPUnit you may organize your unit tests in
test suites, and also give them names. So, for better organizing my tests, I
wanted five directories holding five different test suites which I thought could
be easily configured inside the phpunit.xml file. Well, apparently there was
support for only one test suite and a [ticket opened][3] for such an addition to
the framework. As a result I hacked a little bit the source code and came up with
a [simple patch][4] (really, there is nothing fancy about it) so that now the
config file accepts multiple test suites.

Thanks to [Sebastian Bergmann][5] the [patch got accepted][6] and it will be
available with PHPUnit 3.4

For many (web) developers out there this might be something really, really
trivial and they're right, but this is my first contribution to an open source
project and I'm happy about it. Some time ago, reading blog post of [Andrei Maxim][7]
(a fellow web developer) I got inspired and said to myself that I should too
contribute some code to an open source project (he wanted a commit though, not a
patch). Well, this was my first step. More to come... I hope.


[1]: http://www.phpunit.de/manual/current/en/appendixes.configuration.html#appendixes.configuration.phpunit
[2]: http://www.phpunit.de/
[3]: http://www.phpunit.de/ticket/623
[4]: http://www.phpunit.de/ticket/623#comment:2
[5]: http://sebastian-bergmann.de/
[6]: http://www.phpunit.de/changeset/4423
[7]: http://andreimaxim.ro/
