--------------------------------------
title: Lambdas and closures in PHP 5.3
author: Ionuț G. Stan
date: April 03, 2009
--------------------------------------


[Beginning with PHP 5.3][1] we'll be able to write anonymous functions and build
closures around them - almost the same way we do it in JavaScript. I'd like to
introduce these to those of you unaware of these new possibilities in this little
blog post.


Defining a lambda
-----------------
The most simple way to define a lambda can be find below. It's exactly the same
way JavaScript handles it. One has to assing a function to a variable.

~~~ {.php}
<?php

$lambda = function() {
    return 'Hello World';
}; // <- this semicolon is mandatory, unlike JavaScript

echo $lambda();
~~~


Creating closures
-----------------
However, if we want closures, we have to do something more and this because the
way scope is designed in PHP where functions don't get easy access to variables
declared outside them. If we want that with a normal (old style) function, we
need to import them using the <code>global</code> keyword. Following the same
idea, in order to capture a variable into a closure we need to `use` it:

~~~ {.php}
<?php

$word = ' World';
$lambda = function() use($word) {
    return 'Hello' . $word;
};

echo $lambda();
~~~


Mutable closures
----------------
Now, our anonymous functions has access to `$word`. But *there's a gotcha* right
here. It has read only access to `$word`. We may try to modify `$word` inside our
function, but those changes won't be visible outside it. So, here we are, introducing
the third thing we need to know about lambdas and closures in PHP. In order to be
able to modify a closed variable, we need to import it using the reference operator:

~~~ {.php}
<?php

$word = ' World';
$lambda = function() use(& $word) {
    $result = 'Hello' . $word;
    $word = 'Bye World';
    return $result;
};

echo $lambda();
echo $word;
~~~

This time, `$word` can and will be modified. The variable inside the closure is
mutable.


Some history about the future
-----------------------------
Although, as of yet, a stable version of PHP 5.3 is not yet out, I should mention
that in the process of bringing lambdas and closures to the language there was a
particular property of these in that they were able to automagically import the
`$this` pointer if the function was defined inside a class. Not long after, some
people thought about writing PHP in the prototypal style of JavaScript, thus there
were some discussion that lead the PHP internals to temporarily remove the magic
import feature. The main reason was that they had to push the final version out
sooner and any new feature would have meant delays. Nevertheless, this feature
has been postponed for PHP 6 in which we may get some niceties that should allow
us to more easily write code in a monkey patching/prototypal style.


[1]: /posts/2009-04-01-what-is-new-in-php-5.3.html
