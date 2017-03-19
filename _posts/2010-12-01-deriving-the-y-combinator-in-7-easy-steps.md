---
title: Deriving the Y Combinator in 7 Easy Steps
author: Ionuț G. Stan
date: December 01, 2010
---


The [Y Combinator][1] is a method of implementing recursion in a programming
language that does not support it natively (actually, it's used more for
exercising programming brains). The requirement, though, is that language to
support anonymous functions.

I chose JavaScript for deriving the Y Combinator, starting from the definition
of a recursive factorial function, using a step-by-step transformation over
the initial function.

Update
------
There's now a [Chinese translation][2] of this article as well as a [Clojure port][3].


Step 1
------
The initial implementation, using JavaScript's built-in recursion mechanism.

~~~js
var fact = function (n) {
    if (n < 2) return 1;
    return n * fact(n - 1);
};
~~~


Step 2
------
What would be the simplest thing to do to obtain basic recursion? We could
just define a function which receives itself as an argument and calls that
argument with the same argument. That's an infinite loop of course, and would
cause a stack overflow.

~~~js
(function (f) {
    f(f);
})(function (f) {
    f(f);
});
~~~

Let's use the above pattern for our factorial function. There is however a
small difference. The factorial function receives an argument which we don't
know yet, so what we want is to return a function which takes that argument.
That function can then be used to compute factorial numbers. Also, this is
what makes our implementation to not result into an infinite loop.

~~~js
var fact = (function (f) {
    return function (n) {
        // termination condition
        if (n < 2) return 1;

        // because f returns a function, we have a double function call.
        return n * f(f)(n - 1);
    };
})(function (f) {
    return function (n) {
        // termination condition
        if (n < 2) return 1;

        // because f returns a function, we have a double function call.
        return n * f(f)(n - 1);
    };
});
~~~


Step 3
------
At this point we have some ugly duplication in there. Let's hide it away into
a helper function called `recur`.

~~~js
var recur = function (f) {
    return f(f);
};

var fact = recur(function (f) {
    return function (n) {
        if (n < 2) return 1;

        // because f returns a function, we have a double function call.
        return n * f(f)(n - 1);
    };
});
~~~


Step 4
------
The problem with the above version is that double function call. We want to
eliminate it so that the implementation of this factorial is similar with
the recursive version. How can we do that?

We can use a helper function that takes a numeric argument and performs the
double call. The trick is though to keep this helper function in the same
environment where `f` is visible, so that `g` can actually call `f`.

~~~js
var recur = function (f) {
    return f(f);
};

var fact = recur(function (f) {
    var g = function (n) {
        return f(f)(n);
    };

    return function (n) {
        if (n < 2) return 1;

        // no more double call, g is a function which takes a numeric arg
        return n * g(n - 1);
    };
});
~~~


Step 5
------
The above works nice, but the definition contains so much clutter code. We
can hide it away inside yet another helper function, keeping almost just the
definition of factorial.

~~~js
var recur = function (f) {
    return f(f);
};

var wrap = function (h) {
    return recur(function (f) {
        var g = function (n) {
            return f(f)(n);
        };

        return h(g);
    });
};

var fact = wrap(function (g) {
    return function (n) {
        if (n < 2) return 1;
        return n * g(n - 1);
    };
});
~~~


Step 6
------
Let's inline the definition of `g` inside `wrap` because we only call it once.

~~~js
var recur = function (f) {
    return f(f);
};

var wrap = function (h) {
    return recur(function (f) {
        return h(function (n) {
            return f(f)(n);
        });
    });
};

var fact = wrap(function (g) {
    return function (n) {
        if (n < 2) return 1;
        return n * g(n - 1);
    };
});
~~~


Step 7
------
Now, if we also inline the definition of `recur` function inside `wrap` we end
up with the famous Y Combinator.

~~~js
var Y = function (h) {
    return (function (f) {
        return f(f);
    })(function (f) {
        return h(function (n) {
            return f(f)(n);
        });
    });
};

var fact = Y(function (g) {
    return function (n) {
        if (n < 2) return 1;
        return n * g(n - 1);
    };
});
~~~


The End
-------
I hope you enjoyed it!


[1]: http://en.wikipedia.org/wiki/Fixed_point_combinator
[2]: http://cnblogs.com/windydays/archive/2012/04/09/2439519.html
[3]: http://legacyblog.citizen428.net/blog/2010/12/14/clojure-deriving-the-y-combinator-in-7-stolen-steps/
