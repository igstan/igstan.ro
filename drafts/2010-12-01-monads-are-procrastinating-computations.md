----------------------------------------------
title: Monads are Procrastinating Computations
author: Ionuț G. Stan
date: November 30, 2010
----------------------------------------------


For the past three weeks I've been hard at work learning more about Haskell. As
always, I'm not using just one source for my readings, but many. I've used Real
World Haskell, Programming in Haskell, and numerous other articles from the
Haskell wiki or elsewhere on the Internet.


For the past two-three weeks I've been working hard studying monads. I'm still
learning Haskell, and to be honest I thought I know what monads are all about,
but when I wanted to write a little Haskell library, just to sharpen up my
skills, I realized that while I understand the way monadic `bind` (`>>=`) and
`return` work, I had no understanding of where that state comes in. So, most
likely I had no understanding at all. As a result of this I thought I rediscover
monads myself using JavaScript. The plan was basically the same as that used
when I derived the [Y Combinator][2].
Also, I chose JavaScript because it forces you to write some code that Haskell
readily hides for you thanks to its terse syntax or different semantics (built-in
function currying). Lastly, I learn best by comparison; from the intersection
of similar concepts presented in slightly different ways.

The work presented below is of course the result of several days of pondering
around the subject and reading diverse materials. But I think I have managed to
synthesize the essence of procedural, object-oriented, and functional programming.
And, of course, understand monads.

It all revolves around state. Both objects and monads are different, but similar
nevertheless, responses to the problem of state. However, this problem is divided
in two -- we have mutable state, and we have immutable state. Also, different
programming paradigms choose to deal with state differently. Some do it explicitly,
while others do it implicitly. Combining all these together we get this table
showing how state is represented in different programming paradigms.

+---------------+--------------+------------------------+
|   **state**   | **explicit** | **implicit**           |
+---------------+--------------+------------------------+
|   **mutable** | procedural   | object-oriented        |
+---------------+--------------+------------------------+
| **immutable** | functional   | functional with monads |
+---------------+--------------+------------------------+

If you find that table hard to read, here's the more human-friendly version of
it.

+--------------------------+------------------------------------+
| explicit mutable state   | procedural programming             |
+--------------------------+------------------------------------+
| implicit mutable state   | object-oriented programming        |
+--------------------------+------------------------------------+
| explicit immutable state | functional programming             |
+--------------------------+------------------------------------+
| implicit immutable state | functional programming with monads |
+--------------------------+------------------------------------+


One of the materials that I used in my studies is a paper called [Monadic Parser
Combinators][1] written by two very prolific gentlemen, Graham Hutton and Erik
Meijer. The paper talks mainly about parsers, and it's indeed a very good one
regarding parsers, nevertheless it's also a good introduction to monads. Graham
Hutton uses parsers as a pedagogic material in his book "Programming in Haskell".
The authors of Real World Haskell also use a simple parser implementation for
introducing the reader to the realms of monads. I could have done this today too,
but I decided that I wanted a simple, but useful programming concept that deals
with state. For my purposes I chose a very simple data structure, a stack, and
later on a queue. Both JavaScript and Haskell have built-in support for stacks
in the form of array objects, and lists respectively, but that's not the point
of course.


Explicit Mutable State -- Procedural Programming
------------------------------------------------

~~~ {.javascript}
var push = function (stack, element) {
    stack.elements[stack.size] = element;
    stack.size += 1;
};

var pop = function (stack) {
    stack.size -= 1;
    return stack.elements.splice(-1)[0];
};


var stack = {
  elements: [1,2,3],
  size: 3
};

push(stack, 4);
push(stack, 5);

console.log( pop(stack) );
console.log( pop(stack) );
~~~

<script type="text/javascript">
(function () {
    console.group("Explicit Mutable State (Procedural)");

    var push = function (stack, element) {
        stack.elements[stack.size] = element;
        stack.size += 1;
    };

    var pop = function (stack) {
        stack.size -= 1;
        return stack.elements.splice(-1)[0];
    };

    var stack = {
      elements: [1,2,3],
      size: 3
    };

    push(stack, 4);
    push(stack, 5);

    console.log( pop(stack) );
    console.log( pop(stack) );

    console.groupEnd();
})();
</script>


Implicit Mutable State -- Object-Oriented Programming
-----------------------------------------------------
For the object-oriented representation of a stack I chose an implementation more
similar with what you'd see in a programming language like Java or C# because
that's what most people think about when hearing object-oriented (whereas it's
mostly class-oriented).

<div class="digression">
Here's a version that doesn't try to emulate classes in JavaScript.

~~~ {.javascript}
var createStack = function () {
    var elements = [];
    var size     = 0;

    return {
        push: function (element) {
            elements[size] = element;
            size += 1;
        },

        pop: function () {
            size -= 1;
            return elements.splice(-1)[0];
        }
    };
};
~~~

</div>

~~~ {.javascript}
var Stack = function () {
    this.elements = [];
    this.size     = 0;
};

Stack.prototype.push = function (element) {
    this.elements[this.size] = element;
    this.size += 1;
};

Stack.prototype.pop = function () {
    this.size -= 1;
    return this.elements.splice(-1)[0];
};


var stack = new Stack;
stack.push(4);
stack.push(5);

console.log( stack.pop() );
console.log( stack.pop() );
~~~

<script type="text/javascript">
(function () {
    console.group("Implicit Mutable State (Object-Oriented)");

    var Stack = function () {
        this.elements = [];
        this.size     = 0;
    };

    Stack.prototype.push = function (element) {
        this.elements[this.size] = element;
        this.size += 1;
    };

    Stack.prototype.pop = function () {
        this.size -= 1;
        return this.elements.splice(-1)[0];
    };


    var stack = new Stack;
    stack.push(4);
    stack.push(5);

    console.log( stack.pop() );
    console.log( stack.pop() );

    console.groupEnd();
})();
</script>

Explicit Immutable State -- Functional Programming
--------------------------------------------------
Instead of modifying the stack argument, it uses it to create and return a new
one.

~~~ {.javascript}
var push = function (stack, element) {
    return {
        elements : [element].concat(stack.elements), // concat creates a new array
        size     : stack.size + 1
    };
};

var pop = function (stack) {
    return [
        stack.elements[0],
        {
            elements : stack.elements.slice(1), // slice creates a new array
            size     : stack.size - 1
        }
    ];
};


var stack = {
  elements: [1,2,3],
  size: 3
};

var result0 = push(stack, 4);
var result1 = push(result0, 5);

var result2 = pop(result1);
var result3 = pop(result2[1]);

console.log( result2[0] );
console.log( result3[0] );
~~~

<script type="text/javascript">
(function () {
    console.group("Explicit Immutable State (Functional Programming) 1");

    var push = function (stack, element) {
        return {
            elements : [element].concat(stack.elements), // concat creates a new array
            size     : stack.size + 1
        };
    };

    var pop = function (stack) {
        return [
            stack.elements[0],
            {
                elements : stack.elements.slice(1), // slice creates a new array
                size     : stack.size - 1
            }
        ];
    };


    var stack = {
      elements: [1,2,3],
      size: 3
    };

    var result0 = push(stack, 4);
    var result1 = push(result0, 5);

    var result2 = pop(result1);
    var result3 = pop(result2[1]);

    console.log( result2[0] );
    console.log( result3[0] );

    console.groupEnd();
})();
</script>

Implicit Immutable State -- Monads
----------------------------------

Really ugly... let's define a uniform interface for return values maybe we can
spot a pattern.

~~~ {.javascript}
var push = function (stack, element) {
    return [
        undefined, // return a result, even if there's no proper result
        {
            elements : [element].concat(stack.elements),
            size     : stack.size + 1
        }
    ];
};

var pop = function (stack) {
    return [
        stack.elements[0],
        {
            elements : stack.elements.slice(1),
            size     : stack.size - 1
        }
    ];
};


var stack = {
  elements: [1,2,3],
  size: 3
};

var result0 = push(stack, 4);
var result1 = push(result0[1], 5);
var result2 = pop(result1[1]);
var result3 = pop(result2[1]);

console.log( result2[0] );
console.log( result3[0] );
~~~

<script type="text/javascript">
(function () {
    console.group("Explicit Immutable State (Functional Programming) 2");

    var push = function (stack, element) {
        return [
            undefined,
            {
                elements : [element].concat(stack.elements),
                size     : stack.size + 1
            }
        ];
    };

    var pop = function (stack) {
        return [
            stack.elements[0],
            {
                elements : stack.elements.slice(1),
                size     : stack.size - 1
            }
        ];
    };


    var stack = {
      elements: [1,2,3],
      size: 3
    };

    var result0 = push(stack, 4);
    var result1 = push(result0[1], 5);
    var result2 = pop(result1[1]);
    var result3 = pop(result2[1]);

    console.log( result2[0] );
    console.log( result3[0] );

    console.groupEnd();
})();
</script>


Back to the Roots -- Lambda Calculus to the Rescue
--------------------------------------------------


~~~ {.javascript}
var push = function (stack, element, continuation) {
    var newStack = {
        elements : [element].concat(stack.elements),
        size     : stack.size + 1
    };

    continuation(undefined, newStack);
};

var pop = function(stack, continuation) {
    var result = stack.elements[0];
    var newStack = {
        elements : stack.elements.slice(1),
        size     : stack.size - 1
    };

    continuation(result, newStack);
};


var stack0 = {
  elements: [1,2,3],
  size: 3
};

push(stack0, 4, function (result1, stack1) {
    push(stack1, 5, function (result2, stack2) {
        pop(stack2, function (result3, stack3) {
            pop(stack3, function (result4, stack4) {
                console.log( result3 );
                console.log( result4 );
            });
        });
    });
});
~~~

<!-- <script type="text/javascript">
(function () {
    var push = function (stack, element, continuation) {
        var newStack = {
            elements : [element].concat(stack.elements),
            size     : stack.size + 1
        };

        continuation(undefined, newStack);
    };

    var pop = function(stack, continuation) {
        var result = stack.elements[0];
        var newStack = {
            elements : stack.elements.slice(1),
            size     : stack.size - 1
        };

        continuation(result, newStack);
    };

    // -------------------------------------------------------------------------
    // USAGE
    // -------------------------------------------------------------------------
    console.group("Continuation-passing style 1");
    var stack0 = {
      elements: [1,2,3],
      size: 3
    };

    push(stack0, 4, function (result1, stack1) {
        push(stack1, 5, function (result2, stack2) {
            pop(stack2, function (result3, stack3) {
                pop(stack3, function (result4, stack4) {
                    console.log( result3 );
                    console.log( result4 );
                });
            });
        });
    });

    console.groupEnd();
})();
</script> -->



~~~ {.javascript}
var push = function (element, continuation, stack) {
    var newStack = {
        elements : [element].concat(stack.elements),
        size     : stack.size + 1
    };

    continuation(undefined, newStack);
};

var pop = function(continuation, stack) {
    var result = stack.elements[0];
    var newStack = {
        elements : stack.elements.slice(1),
        size     : stack.size - 1
    };

    continuation(result, newStack);
};


var stack0 = {
  elements: [1,2,3],
  size: 3
};

push(4, function (result1, stack1) {
    push(5, function (result2, stack2) {
        pop(function (result3, stack3) {
            pop(function (result4, stack4) {
                console.log( result3 );
                console.log( result4 );
            }, stack3);
        }, stack2);
    }, stack1);
}, stack0);
~~~

<!-- <script type="text/javascript">
(function () {
    var push = function (element, continuation, stack) {
        var newStack = {
            elements : [element].concat(stack.elements),
            size     : stack.size + 1
        };

        continuation(undefined, newStack);
    };

    var pop = function(continuation, stack) {
        var result = stack.elements[0];
        var newStack = {
            elements : stack.elements.slice(1),
            size     : stack.size - 1
        };

        continuation(result, newStack);
    };

    console.group("Continuation-passing style 2");
    var stack0 = {
      elements: [1,2,3],
      size: 3
    };

    push(4, function (result1, stack1) {
        push(5, function (result2, stack2) {
            pop(function (result3, stack3) {
                pop(function (result4, stack4) {
                    console.log( result3 );
                    console.log( result4 );
                }, stack3);
            }, stack2);
        }, stack1);
    }, stack0);

    console.groupEnd();
})();
</script> -->


Currying, or How Functions Procrastinate
----------------------------------------

~~~ {.javascript}
var push = function (element, continuation) {
    return function (stack) {
        var newStack = {
            elements : [element].concat(stack.elements),
            size     : stack.size + 1
        };

        continuation(undefined, newStack);
    };
};

var pop = function(continuation) {
    return function (stack) {
        var result = stack.elements[0];
        var newStack = {
            elements : stack.elements.slice(1),
            size     : stack.size - 1
        };

        continuation(result, newStack);
    };
};


var stack0 = {
  elements: [1,2,3],
  size: 3
};

push(4, function (result1, stack1) {
    push(5, function (result2, stack2) {
        pop(function (result3, stack3) {
            pop(function (result4, stack4) {
                console.log( result3 );
                console.log( result4 );
            })(stack3);
        })(stack2);
    })(stack1);
})(stack0);
~~~

<!-- <script type="text/javascript">
(function () {
    var push = function (element, continuation) {
        return function (stack) {
            var newStack = {
                elements : [element].concat(stack.elements),
                size     : stack.size + 1
            };

            continuation(undefined, newStack);
        };
    };

    var pop = function(continuation) {
        return function (stack) {
            var result = stack.elements[0];
            var newStack = {
                elements : stack.elements.slice(1),
                size     : stack.size - 1
            };

            continuation(result, newStack);
        };
    };


    console.group("Continuation-passing style 3: curried functions");
    var stack0 = {
      elements: [1,2,3],
      size: 3
    };

    push(4, function (result1, stack1) {
        push(5, function (result2, stack2) {
            pop(function (result3, stack3) {
                pop(function (result4, stack4) {
                    console.log( result3 );
                    console.log( result4 );
                })(stack3);
            })(stack2);
        })(stack1);
    })(stack0);

    console.groupEnd();
})();
</script> -->


~~~ {.javascript}
var push = function (element, continuation) {

    return function (stack) {
        var newStack = {
            elements : [element].concat(stack.elements),
            size     : stack.size + 1
        };

        return continuation(undefined)(newStack);
    };

};

var pop = function(continuation) {

    return function (stack) {
        var result = stack.elements[0];
        var newStack = {
            elements : stack.elements.slice(1),
            size     : stack.size - 1
        };

        return continuation(result)(newStack);
    };

};

var passStackAlong = function () {
    return function (stack) {
        return stack;
    };
};


var stack0 = {
  elements: [1,2,3],
  size: 3
};

push(4, function () {
    return push(5, function () {
        return pop(function (result3) {
            return pop(function (result4) {
                console.log( result3 );
                console.log( result4 );

                // without this, we'll get an error
                return passStackAlong();
            });
        });
    });
})(stack0);
~~~

By currying these functions I'm composing suspending the whole computation.

able to compose computations in a suspended state. At the end, after I've
combined all the **combinators**, I just start off the computation by applying
the resulted function.

<!-- <script type="text/javascript">
(function () {
    var push = function (element, continuation) {

        return function (stack) {
            var newStack = {
                elements : [element].concat(stack.elements),
                size     : stack.size + 1
            };

            return continuation(undefined)(newStack);
        };

    };

    var pop = function(continuation) {

        return function (stack) {
            var result = stack.elements[0];
            var newStack = {
                elements : stack.elements.slice(1),
                size     : stack.size - 1
            };

            return continuation(result)(newStack);
        };

    };

    var passStackAlong = function () {
        return function (stack) {
            return stack;
        };
    };

    // -------------------------------------------------------------------------
    // USAGE
    // -------------------------------------------------------------------------
    console.group("Continuation-passing style 4: curried functions");
    var stack0 = {
      elements: [1,2,3],
      size: 3
    };

    push(4, function () {
        return push(5, function () {
            return pop(function (result3) {
                return pop(function (result4) {
                    console.log( result3 );
                    console.log( result4 );

                    // without this, we'll get an error
                    return passStackAlong();
                });
            });
        });
    })(stack0);

    console.groupEnd();
})();
</script> -->


Searching for Patterns
----------------------

~~~ {.javascript}
var enqueue = function (element, continuation) {

    return function (queue) {
        var newQueue = {
            elements : [element].concat(queue.elements),
            size     : queue.size + 1
        };

        return continuation(undefined)(newQueue);
    };

};

var dequeue = function(continuation) {

    return function (queue) {
        var last = queue.size - 1;
        var result = queue.elements[last];
        var newQueue = {
            elements : queue.elements.slice(0, -1),
            size     : queue.size - 1
        };

        return continuation(result)(newQueue);
    };

};

var passQueueAlong = function () {
    return function (queue) {
        return queue;
    };
};


var queue = {
    elements: [],
    size: 0
};

enqueue(4, function () {
    return enqueue(5, function () {
        return dequeue(function (result3) {
            return dequeue(function (result4) {
                console.log( result3 );
                console.log( result4 );

                return passQueueAlong();
            });
        });
    });
})(queue);
~~~

<!-- <script type="text/javascript">
(function () {
    var enqueue = function (element, continuation) {

        return function (queue) {
            var newQueue = {
                elements : [element].concat(queue.elements),
                size     : queue.size + 1
            };

            return continuation(undefined)(newQueue);
        };

    };

    var dequeue = function(continuation) {

        return function (queue) {
            var last = queue.size - 1;
            var result = queue.elements[last];
            var newQueue = {
                elements : queue.elements.slice(0, -1),
                size     : queue.size - 1
            };

            return continuation(result)(newQueue);
        };

    };

    var passQueueAlong = function () {
        return function (queue) {
            return queue;
        };
    };

    // -------------------------------------------------------------------------
    // USAGE
    // -------------------------------------------------------------------------
    console.group("Continuation-passing style 4: queue data structure");
    var queue = {
        elements: [],
        size: 0
    };

    enqueue(4, function () {
        return enqueue(5, function () {
            return dequeue(function (result3) {
                return dequeue(function (result4) {
                    console.log( result3 );
                    console.log( result4 );

                    return passQueueAlong();
                });
            });
        });
    })(queue);

    console.groupEnd();
})();
</script> -->


Abstract Duplication Into Higher-Order Functions
------------------------------------------------

~~~ {.javascript}
var enqueue = function (element) {
    return function (queue) {
        var newQueue = {
            elements : [element].concat(queue.elements),
            size     : queue.size + 1
        };

        return [undefined, newQueue];
    };
};

var dequeue = function () {
    return function (queue) {
        var last = queue.size - 1;
        var result = queue.elements[last];
        var newQueue = {
            elements : queue.elements.slice(0, -1),
            size     : queue.size - 1
        };

        return [result, newQueue];
    };
};

var unit = function () {
    return function (state) {
        return state;
    };
};

var bind = function (context, continuation) {
    return function (state) {
        var result = context(state);
        return continuation(result[0])(result[1]);
    };
};


var queue = {
    elements: [],
    size: 0
};

bind(enqueue(4), function () {
    return bind(enqueue(5), function () {
        return bind(dequeue(), function (a) {
            return bind(dequeue(), function (b) {
                console.log(a);
                console.log(b);

                return unit();
            });
        });
    });
})(queue);
~~~

<!-- <script type="text/javascript">
(function () {
    var enqueue = function (element) {
        return function (queue) {
            var newQueue = {
                elements : [element].concat(queue.elements),
                size     : queue.size + 1
            };

            return [undefined, newQueue];
        };
    };

    var dequeue = function () {
        return function (queue) {
            var last = queue.size - 1;
            var result = queue.elements[last];
            var newQueue = {
                elements : queue.elements.slice(0, -1),
                size     : queue.size - 1
            };

            return [result, newQueue];
        };
    };

    var unit = function () {
        return function (state) {
            return state;
        };
    };

    var bind = function (context, continuation) {
        return function (state) {
            var result = context(state);
            return continuation(result[0])(result[1]);
        };
    };

    // -------------------------------------------------------------------------
    // USAGE
    // -------------------------------------------------------------------------
    console.group("Monads 1: using bind");
    var queue = {
        elements: [],
        size: 0
    };

    bind(enqueue(4), function () {
        return bind(enqueue(5), function () {
            return bind(dequeue(), function (a) {
                return bind(dequeue(), function (b) {
                    console.log(a);
                    console.log(b);

                    return unit();
                });
            });
        });
    })(queue);

    console.groupEnd();
})();
</script> -->


The last two weeks I had some time to investigate a little bit deeper the
programming concept called "monad". Because I thought I have something new to
write about them, I decided to put together this post in which I'll describe
what I've gathered so far, also why I associate monads with procrastination.


What's a Monad
--------------
The most succinct definition that I've found, and which makes a lot of sense
actually, is a quote from a paper called [Monadic Parser Combinators][1],
written by Graham Hutton and Erik Meijer, and it reads:

> The basic idea behind monads is to distinguish the *values* that a computation
> can produce from the *computation* itself.

Sounds like that principle from object-oriented programming called "programming
to an interface", isn't it? Let's see what that means though.

The afore mentioned paper introduces the reader to the concept of monads by using
parsers as an example vehicle. I'll do the same because my work here is highly
influenced by that paper. The difference though is that I'll use JavaScript as
the implementation language. I decided to use JavaScript while studying these
concepts because I've found that I learn easier by means of comparison. JavaScript
is a more familiar place for me than Haskell at this point, and retrospectively
this was a good idea. Using JavaScript I was able to better understand and
appreciate Haskell's powers.

Below, I'll attempt to derive monads by using a simple programming practice; I'll
remove code duplication. Just as I did in a previous post where I [derived the
Y Combinator][2].


What's a Parser
---------------
A parser can be thought of as a *function* that takes a string and returns some
sort of transformed representation, usually an Abstract Syntax Tree (AST). Let's
write down this definition in both Haskell and JavaScript:

~~~ {.haskell}
type Parser a = String -> [(a, String)]
~~~

~~~ {.javascript}
function Parser(input) {
    return [[v, state]];
}
~~~

Now, the reason monads are so omnipresent in a *purely* functional programming
language like Haskell is because side-effects are not possible. That was a problem
that had to be solved.


Making State Explicit
---------------------
Let's imagine for the moment that JavaScript were a purely functional language
too, and try to find a way around the immutability issue. In our parser scenario,
the essential operation which presents side-effects is to consume a single
character from the input string. Let's define an `item` function that given a
certain input state `initialState`, will perform its computation and return the
computed value. First, let's try a mutable scenario:

~~~ {.javascript}
/**
 * Let's assume input is an array, not a string.
 */
function item(input) {
    return input.shift();
}
~~~

Above, we were able to mutate input because JavaScript arrays are objects, so
they're passed by reference, and not by value. Thus, our little function changes
the state of the world outside. What if we couldn't mutate `input`? We can still
perform our calculations, i.e., read the first element from the array, but
instead of modifying the `input` param, we create a new array, identical to the
`input` except that it doesn't present the first element. Also, we will now
return not only the first element, but also the new state, so that the outside
world can access it.

~~~ {.javascript}
function item(input) {
    return [input[0], input.slice(1)];
}
~~~

What we just did was to make state explicit. Now, every caller of `item` has to
explicitly deal with the resulted state, either processing or ignoring it. For
this purpose, let's create a new parser that succeeds in its computation as long
as it can read an single item from the input stream equal with a given char.
Otherwise it fails, and we're going to represent failure by means of an empty
array. We'll see how `char` has to deal with the new state returned by `item`.

~~~ {.javascript}
function char(expectedChar, input) {
    var result = item(input);

    if (result.length === 0) {
        return []; // this means failure
    }

    if (result[0] !== expectedChar) {
        return [];
    }

    // pass the result along as it matches our requirements
    return result;
}
~~~

As you can see, `char` has to make explicit checks for failure before starting
to perform its calculations, which in this very simple case is an equality check.

All is well and dandy, but a parser library able to match single characters is
of no use. Let's define a third parser, that is capable of matching a string of
characters.

~~~ {.javascript}
function string(expectedString, input) {
    // base rule of recursion
    if (expectedString === "") {
        return ["", input];
    }

    var first = char(expectedString[0], input);

    if (first.length === []) {
        return [];
    }

    // recursive rule
    var rest = string(expectedString.substr(1), first[1]);

    return [first[0] + rest[0], rest[1]];
}
~~~

That was a little bit trickier than the definition of `char`. The main reason is
that we had to explicitly deal with resulted state, check for errors, and extract
the value that actually interests us from the parsed result. We also had to make
sure we're returning a similar result to those returned by `item` and `char`.
This is a pattern present in all of the above three parsers, and trust me, it
will appear in any other combinator we might want to implement. Can we remove
the boilerplate?


Abstracting Boilerplate Code
----------------------------
We can notice above, that `item` is a primitive parser in that it is the only
one that generates a new state, the others are simply passing it along to the
caller. Let's try to simplify what we have so far and see if we can extract
the repetition into some abstraction.

~~~ {.javascript}
function a(state) {
    // do something with state
    return [value, newState];
}
function b(x, state) {
    [value, newState] = a(state);
    // do something with value
    return [value, newState];
}
function c(y, state) {
    [value, newState] = b(x, state);
    // do some other thing with value
    return [value, newState];
}

// So.. the only thing that varies from combinator to combinator is that thing
// that we replaced with a comment. We can now extract the repetition inside
// a higher order function, what will receive the peculiar computation as an
// argument and wrap it in between that boilerplate code. Let's call it `bind`.
function bind(parser, action, state) {
    [value, newState] = parser(state);
    [value, newState] = action(value, newState);
    return [value, newState];
}
~~~



`this` in OO languages can be thought of as `return` in Haskell. What OO languages
lack is an equivalent for `>>=`. Hmm, do they? In JavaScript at least?

References:

 - http://blog.sigfpe.com/2007/04/trivial-monad.html
 - http://www.valuedlessons.com/2008/01/monads-in-python-with-nice-syntax.html


[1]: javascript:alert("put link here");
[2]: /posts/2010-12-01-deriving-the-y-combinator-in-7-easy-steps.html
