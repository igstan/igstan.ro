---------------------------------
title: PHP's ErrorException class
author: Ionuț G. Stan
date: March 18, 2009
---------------------------------

Did you know <abbr title="PHP HyperText Preprocessor">PHP</abbr> has an
[`ErrorException`][1] class</a> that solves the problem of throwing exceptions
from an [error handler function][2]?

What problem?

Well, if you throw a normal `Exception` from such a handler, the file name and
line number of the `Exception` will be set to match the file and line where the
`Exception` was actually thrown and not the place where the error happened.
There was no way to extend an Exception class and provide the correct information
as `Exception`'s `$file` and `$line` properties are private and there are no
setters for them, only getters.

`ErrorException` solves this problem by overriding the `Exception` constructor,
allowing us to pass up to five arguments. From these five arguments, four have
the same meaning as the four arguments passed to the error handler function:
`$errno`, `$errstr`, `$errfile`, `$errline`. By passing along these arguments to
the `ErrorException` constructor we get a more meaningful exception from our error
handler.


[1]: http://www.php.net/manual/en/class.errorexception.php
[2]: http://www.php.net/manual/en/function.set-error-handler.php
