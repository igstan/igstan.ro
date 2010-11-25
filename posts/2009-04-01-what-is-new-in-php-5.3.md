----------------------------
title: What's new in PHP 5.3
author: Ionuț G. Stan
date: April 1, 2009
----------------------------


A few weeks ago, [PHP 5.3 RC1 has been released][1] and I expect the final version
to be out in no more than a month. I'm watching its development since the beginning
of 2008 and am really eager to see it in production. The reason for this impatience
is that it brings really cool features to the language and I'd like to enumerate
some of them in order of my preferences. Initially I also wanted to briefly describe
them, but apparently there was to much to talk about in just one post, therefore
each feature in the list below will, eventually, point to a more detailed post
about the respective feature. So here's what I like best:


 1. [Lambdas and closures][2]
 2. Callable classes
 3. Namespaces
 4. The Phar extension
 5. Late static binding

There are some other features beside the above mentioned, but these are easier to
present so I'll shortly describe them here:


`__callStatic`
--------------

This is just like the __call we all know except it is designed to work when calling
methods in a static context:

~~~ {.php}
<?php

class Test
{
    public static function __callStatic($method, $args)
    {
        return array($method, $args);
    }
}

var_dump(Test::dummyMethod('with dummy argument'));
~~~


Nowdoc strings
--------------
We all know [heredoc][3] strings and the fact they are parsed by the PHP engine
for variable interpolation. They're also good when we have large strings with
both single and double quotes, because it saves us from escaping them. Some PHP
internals thought though, that the overhead produced for variable interpolation
is to big, so they came up with [nowdoc][4] strings. This is just like heredoc
save for the variable interpolation. Here's an example:

~~~ {.php}
<?php

$here_doc = <<<STR
Some random string with $variable interpolation...
STR;

$now_doc = <<<'STR'
Some random string without $variable interpolation...
STR;
~~~


Ternary shortcut (`?:`)
-----------------------
This is just like the old ternary operator except that we can leave out the middle
statement. [The rule is][5] that, if the left-hand side expression evaluates to
true, its result is returned, otherwise it will return the result of the result
of right-hand side expression:

~~~ {.php}
<?php

var_dump('' ?: 'there was an empty string');
var_dump('I am not empty' ?: 'there was an empty string');
~~~


Limited `goto`
--------------
Honestly, I don't yet understand why this construct is limited because I have never
worked with gotos. All I know is that we cannot use goto statements inside loops,
this will cause a fatal error to be thrown. Anyway, here's a [basic example taken
straight from the manual][6]:

~~~ {.php}
<?php

goto a;
echo 'Foo';

a:
echo 'Bar';
~~~


[1]: http://www.php.net/archive/2009.php#id2009-03-24-1
[2]: /posts/2009-04-03-lambdas-and-closures-in-php-5.3.html
[3]: http://www.php.net/manual/en/language.types.string.php#language.types.string.syntax.heredoc
[4]: http://www.php.net/manual/en/language.types.string.php#language.types.string.syntax.nowdoc
[5]: http://php.net/ternary#language.operators.comparison.ternary
[6]: http://www.php.net/manual/en/control-structures.goto.php
