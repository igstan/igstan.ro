--------------------------------------------------------------------------------
title: Understanding Monads With JavaScript
author: Ionuț G. Stan
date: May 02, 2011
--------------------------------------------------------------------------------

For the past weeks I've been working hard studying monads. I'm still learning
Haskell, and to be honest I thought I knew what monads are all about, but when
I wanted to write a little Haskell library, just to sharpen up my skills, I
realized that while I understood the way monadic `bind` (`>>=`) and `return`
work, I had no understanding of where that state comes from. So, most likely I
had no understanding at all. As a result of this I thought I rediscover monads
myself using JavaScript. The plan was basically the same as that used when I
derived the [Y Combinator][1]: start from the initial problem (dealing with
explicit immutable state in this case), and work my way up to the solution by
applying simple code transformations.

Also, I chose JavaScript because it forces you to write some code that Haskell
readily hides for you thanks to its terse syntax or different semantics (lambda
expressions, operators, and built-in function currying). Lastly, I learn best by
comparison, which is why I tried it in CoffeeScript and Scheme too. Here are the
GitHub gists for the latter two:

- CoffeeScript: [https://gist.github.com/936519][17]
- Scheme: [https://gist.github.com/936695][18]


Constraints
-----------
In this article I'll limit my problem to the state monad. Understanding the state
monad is good enough to have an idea what monads are all about. So here are the
solution constraints.

 - **no mutable state**\
   Haskell makes use of the state monad because it does not allow mutable state.
 - **no explicit state**\
   When you don't have mutable state, you have to thread residual state around.
   Typing and reading all those intermediate states is not pleasant. Monads try
   to hide all this plumbing. You'll see what I mean in a moment.
 - **no code duplication**\
   This goes hand in hand with the previous point, but I still put it here
   because in my experience removal of code duplication is a powerful tool to
   explore new grounds.



Too Long; Won't Read
--------------------
This article is a pretty dense one, so I thought I should add some additional
material to it. That's why I recorded a little video with all the steps that are
described below. It's sort of a <abbr title="Too Long; Didn't Read">tl;dr</abbr>
version, and it should help visualize the transitions more easily, but most
likely the video won't make too much sense if you won't read the whole article.

I advise you watch it [directly on Vimeo][16], where it's available in HD.

<div style="text-align:center; margin-bottom:30px;">
  <iframe src="http://player.vimeo.com/video/23125621?title=0&amp;byline=0&amp;portrait=0" width="650" height="406" frameborder="0"></iframe>
</div>



Derivation Vehicle
------------------
I'll use a stack as my derivation vehicle because it's an easy to understand
data structure, and its usual implementation is done using mutable state. First,
here's how you'd normally use a stack in JavaScript.

~~~ {.javascript}
var stack = [];

stack.push(4);
stack.push(5);
stack.pop(); // 5
stack.pop(); // 4
~~~

JavaScript array objects have the usual methods one would expect from a stack,
`push` and `pop`. What I don't like about it is that it mutates state. Well, I
don't it like for the sake of this article, at least.

Each step I'll describe is a working step. Just open you're browser's console
and reload this page. You should see several console groups with the string `5 : 4`
logged inside. However, in the body of the article I'll only present those parts
that differ from the previous steps.



A Stack With Explicit Handling of State
---------------------------------------
The obvious solution to avoid mutable state is to construct a new state container
every time we need mutation. Here's how it can look like in JavaScript (note that
`concat` and `slice` are two `Array` methods that do not mutate the object they're
called on, instead they create new `Array` objects):

~~~ {.javascript}
var push = function (element, stack) {
  var newStack = [element].concat(stack);

  return newStack;
};

var pop = function (stack) {
  var value = stack[0];
  var newStack = stack.slice(1);

  return { value: value, stack: newStack };
};

var stack0 = [];

var stack1 = push(4, stack0);
var stack2 = push(5, stack1);
var result0 = pop(stack2);        // {value: 5, stack: [4]}
var result1 = pop(result0.stack); // {value: 4, stack: []}
~~~

As you can see, both `push` and `pop` return a residual stack, the resulted state.
`pop` additionally returns the popped value. Each subsequent stack operation uses
the previous stack, but this may not be easily observable because of differences
in representation of return values. However, code duplication can be emphasized
by normalizing return values. We'll have `push` return a dummy `undefined` value.

~~~ {.javascript}
var push = function (element, stack) {
  var value = undefined;
  var newStack = [element].concat(stack);

  return { value: value, stack: newStack };
};

var pop = function (stack) {
  var value = stack[0];
  var newStack = stack.slice(1);

  return { value: value, stack: newStack };
};

var stack0 = [];

var result0 = push(4, stack0);
var result1 = push(5, result0.stack);
var result2 = pop(result1.stack); // {value: 5, stack: [4]}
var result3 = pop(result2.stack); // {value: 4, stack: []}
~~~

That's the kind of duplication I was talking earlier. Duplication that also means
explicit handling of state.

<script>
(function () {
  var push = function (element, stack) {
    var value = undefined;
    var newStack = [element].concat(stack);

    return { value: value, stack: newStack };
  };

  var pop = function (stack) {
    var value = stack[0];
    var newStack = stack.slice(1);

    return { value: value, stack: newStack };
  };

  var stack0 = [];

  var result0 = push(4, stack0);
  var result1 = push(5, result0.stack);
  var result2 = pop(result1.stack);
  var result3 = pop(result2.stack);

  console.group("Step 1: stack with explicit handling of state");
  console.log(result2.value + " : " + result3.value);
  console.groupEnd();
})();
</script>



Transforming to Continuation-Passing Style
------------------------------------------
Now, I'll replace those intermediate result variables with functions and
parameters. I want this because I find it easier to abstract over functions and
parameters than over simple variables. To do this, I'll create a small helper
function, called `bind`, which does nothing more than just apply a continuation
callback to the stack operation result. In other works, it *binds* a continuation
to a stack operation.

~~~ {.javascript}
var bind = function (value, continuation) {
  return continuation(value);
};

var stack0 = [];

var finalResult = bind(push(4, stack0), function (result0) {
  return bind(push(5, result0.stack), function (result1) {
    return bind(pop(result1.stack), function (result2) {
      return bind(pop(result2.stack), function (result3) {
        var value = result2.value + " : " + result3.value;
        return { value: value, stack: result3.stack };
      });
    });
  });
});
~~~

<script>
(function () {
  var push = function (element, stack) {
    var value = undefined;
    var newStack = [element].concat(stack);

    return { value: value, stack: newStack };
  };

  var pop = function (stack) {
    var value = stack[0];
    var newStack = stack.slice(1);

    return { value: value, stack: newStack };
  };

  var bind = function (value, continuation) {
    return continuation(value);
  };

  var stack0 = [];

  var finalResult = bind(push(4, stack0), function (result0) {
    return bind(push(5, result0.stack), function (result1) {
      return bind(pop(result1.stack), function (result2) {
        return bind(pop(result2.stack), function (result3) {
          var value = result2.value + " : " + result3.value;
          return { value: value, stack: result3.stack };
        });
      });
    });
  });

  console.group("Step 2: transforming to continuation-passing style");
  console.log(finalResult);
  console.groupEnd();
})();
</script>

The return value of the whole expression, stored in `finalResult`, has the same
type as the return value of a single `push` or `pop` operation. We want to have
consistent interfaces.


Currying `push` and `pop`
-------------------------
Next, we want to be able to detach the stack arguments from `push` and `pop`. We
want this because the intention is to have `bind` thread them behind the scenes.

For this we'll apply another lambda calculus trick called function currying. An
alternative name could be function application procrastination.

Now, instead of calling `push(4, stack0)`, we'll call `push(4)(stack0)`. In
Haskell we wouldn't even need this step, because its functions are curried by
default.

~~~ {.javascript}
var push = function (element) {
  return function (stack) {
    var value = undefined;
    var newStack = [element].concat(stack);

    return { value: value, stack: newStack };
  };
};

var pop = function () {
  return function (stack) {
    var value = stack[0];
    var newStack = stack.slice(1);

    return { value: value, stack: newStack };
  };
};

var stack0 = [];

var finalResult = bind(push(4)(stack0), function (result0) {
  return bind(push(5)(result0.stack), function (result1) {
    return bind(pop()(result1.stack), function (result2) {
      return bind(pop()(result2.stack), function (result3) {
        var value = result2.value + " : " + result3.value;
        return { value: value, stack: result3.stack };
      });
    });
  });
});
~~~

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (value, continuation) {
    return continuation(value);
  };

  var stack0 = [];

  var finalResult = bind(push(4)(stack0), function (result0) {
    return bind(push(5)(result0.stack), function (result1) {
      return bind(pop()(result1.stack), function (result2) {
        return bind(pop()(result2.stack), function (result3) {
          var value = result2.value + " : " + result3.value;
          return { value: value, stack: result3.stack };
        });
      });
    });
  });

  console.group("Step 3: currying `push` and `pop`");
  console.log(finalResult);
  console.groupEnd();
})();
</script>



Preparing `bind` to Handle Intermediate Stacks
----------------------------------------------
As I said in the previous section, I'd like `bind` to handle the passing of the
explicit stack arguments. First, let's have `bind` accept a stack as its last
parameter, but in a curried way, i.e. `bind` now returns a function which takes
a stack. Also, `push` and `pop` are now partially applied, i.e. we longer pass
them the stack manually. `bind` will handle this instead.

~~~ {.javascript}
var bind = function (stackOperation, continuation) {
  return function (stack) {
    return continuation(stackOperation(stack));
  };
};

var stack0 = [];

var finalResult = bind(push(4), function (result0) {
  return bind(push(5), function (result1) {
    return bind(pop(), function (result2) {
      return bind(pop(), function (result3) {
        var value = result2.value + " : " + result3.value;
        return { value: value, stack: result3.stack };
      })(result2.stack);
    })(result1.stack);
  })(result0.stack);
})(stack0);
~~~

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackOperation, continuation) {
    return function (stack) {
      return continuation(stackOperation(stack));
    };
  };

  var stack0 = [];

  var finalResult = bind(push(4), function (result0) {
    return bind(push(5), function (result1) {
      return bind(pop(), function (result2) {
        return bind(pop(), function (result3) {
          var value = result2.value + " : " + result3.value;
          return { value: value, stack: result3.stack };
        })(result2.stack);
      })(result1.stack);
    })(result0.stack);
  })(stack0);

  console.group("Step 4: preparing `bind` to handle the intermediary stacks");
  console.log(finalResult);
  console.groupEnd();
})();
</script>



Removing Trailing Stacks
------------------------
We're now able to hide the intermediary stacks by modifying `bind` to inspect
the return value of a `stackOperation`, extract the stack and use it as an
argument to the return value of the continuation callback, which must be a
function that receives a stack. That's why we also have to wrap the final result
(`return result2.value + " : " + result3.value`) inside an anonymous function
that will receive a stack.

~~~ {.javascript}
var bind = function (stackOperation, continuation) {
  return function (stack) {
    var result = stackOperation(stack);
    var newStack = result.stack;
    return continuation(result)(newStack);
  };
};

var computation = bind(push(4), function (result0) {
  return bind(push(5), function (result1) {
    return bind(pop(), function (result2) {
      return bind(pop(), function (result3) {
        var value = result2.value + " : " + result3.value;

        // We need this anonymous function because we changed the protocol
        // of the continuation. Now, each continuation must return a
        // function which accepts a stack.
        return function (stack) {
          return { value: value, stack: stack };
        };
      });
    });
  });
});

var stack0 = [];
var finalResult = computation(stack0);
~~~

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackOperation, continuation) {
    return function (stack) {
      var result = stackOperation(stack);
      var newStack = result.stack;
      return continuation(result)(newStack);
    };
  };

  var computation = bind(push(4), function (result0) {
    return bind(push(5), function (result1) {
      return bind(pop(), function (result2) {
        return bind(pop(), function (result3) {
          var value = result2.value + " : " + result3.value;

          // We need this anonymous function because we changed the protocol
          // of the continuation. Now, each continuation must return a
          // function which accepts a stack.
          return function (stack) {
            return { value: value, stack: stack };
          };
        });
      });
    });
  });

  var stack0 = [];
  var finalResult = computation(stack0);

  console.group("Step 5: remove trailing stacks");
  console.log(finalResult);
  console.groupEnd();
})();
</script>


Hiding the Final Residual Stack
-------------------------------
In the previous step, we hid away several intermediate stacks, but exposed a new
one in the function that wraps the final result value. We can hide this trace of
a stack by writing another helper function that I'll call `result`. Additionally,
this will also hide the internal representation of the state we're keeping, i.e.
a struct with two fields, `value` and `stack`.

~~~ {.javascript}
var result = function (value) {
  return function (stack) {
    return { value: value, stack: stack };
  };
};

var computation = bind(push(4), function (result0) {
  return bind(push(5), function (result1) {
    return bind(pop(), function (result2) {
      return bind(pop(), function (result3) {

        return result(result2.value + " : " + result3.value);

      });
    });
  });
});

var stack0 = [];
var finalResult = computation(stack0);
~~~

This is exactly what the `return` functions does in Haskell. It wraps the
computation result inside a monad. In our case it wraps the result in a closure
which accepts a stack. But that's basically what the state monad is, a function
that accepts its state. Another way to view `result`/`return` is like a factory
function that creates a new stateful context around the value we provide it with.

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackOperation, continuation) {
    return function (stack) {
      var result = stackOperation(stack)
        return continuation(result)(result.stack);
    };
  };

  var result = function (value) {
    return function (stack) {
      return { value: value, stack: stack };
    };
  };

  var computation = bind(push(4), function (result0) {
    return bind(push(5), function (result1) {
      return bind(pop(), function (result2) {
        return bind(pop(), function (result3) {

          return result(result2.value + " : " + result3.value);

        });
      });
    });
  });

  var stack0 = [];
  var finalResult = computation(stack0);

  console.group("Step 6: hiding the final residual stack");
  console.log(finalResult);
  console.groupEnd();
})();
</script>



Keeping State Internal
----------------------
We don't want our continuation callbacks to have to traverse or even know about
the struct returned by `push` or `pop`, which actually represents the internals
of the monad. So, we'll modify `bind` to pass just the minimum required data to
the callback.

~~~ {.javascript}
var bind = function (stackOperation, continuation) {
  return function (stack) {
    var result = stackOperation(stack);
    return continuation(result.value)(result.stack);
  };
};

var computation = bind(push(4), function () {
  return bind(push(5), function () {
    return bind(pop(), function (result1) {
      return bind(pop(), function (result2) {

        return result(result1 + " : " + result2);

      });
    });
  });
});

var stack0 = [];
var finalResult = computation(stack0);
~~~

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackOperation, continuation) {
    return function (stack) {
      var result = stackOperation(stack);
      return continuation(result.value)(result.stack);
    };
  };

  var result = function (value) {
    return function (stack) {
      return { value: value, stack: stack };
    };
  };

  var computation = bind(push(4), function () {
    return bind(push(5), function () {
      return bind(pop(), function (result1) {
        return bind(pop(), function (result2) {
          return result(result1 + " : " + result2);
        });
      });
    });
  });

  var stack0 = [];
  var finalResult = computation(stack0);

  console.group("Step 7: keeping state internal");
  console.log(finalResult);
  console.groupEnd();
})();
</script>


Evaluating The Stack Computation
--------------------------------
Once we're able to compose stack operations this way, we'll also want to run
these computations and do something with the result. This is generally called
evaluation of the monad. In Haskell, the state monad provides three functions
for evaluating the state monad: `runState`, `evalState`, and `execState`.

For the purpose of this article though, I'll replace the "State" suffix with
"Stack".

~~~ {.javascript}
// Returns both the result and the final state.
var runStack = function (stackOperation, initialStack) {
  return stackOperation(initialStack);
};

// Returns only the computed result.
var evalStack = function (stackOperation, initialStack) {
  return stackOperation(initialStack).value;
};

// Returns only the final state.
var execStack = function (stackOperation, initialStack) {
  return stackOperation(initialStack).stack;
};

var stack0 = [];

console.log(runStack(computation, stack0));
// { value="5 : 4", stack=[]}

console.log(evalStack(computation, stack0));
// 5 : 4

console.log(execStack(computation, stack0));
// []
~~~

If all we're interested in is the final computed value, then `evalStack` is what
we need. It will trigger the whole monadic computation, drop the final resulted
state and return the computed value. Using this function we can extract a value
out of its monadic context.

If you've ever heard that you can't escape a monad, then let me tell that this
is true just in a small number of cases, like the IO monad for example. But
that's another story. The point is that you can get out of the state monad.


<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackOperation, continuation) {
    return function (stack) {
      var result = stackOperation(stack);
      return continuation(result.value)(result.stack);
    };
  };

  var result = function (value) {
    return function (stack) {
      return { value: value, stack: stack };
    };
  };

  var runStack = function (stackOperation, initialStack) {
    return stackOperation(initialStack);
  };

  var evalStack = function (stackOperation, initialStack) {
    return stackOperation(initialStack).value;
  };

  var execStack = function (stackOperation, initialStack) {
    return stackOperation(initialStack).stack;
  };

  var computation = bind(push(4), function () {
    return bind(push(5), function () {
      return bind(pop(), function (result1) {
        return bind(pop(), function (result2) {
          return result(result1 + " : " + result2);
        });
      });
    });
  });

  var stack0 = [];

  console.group("Step 8: evaluating the stack computation");
  console.log("runState", runStack(computation, stack0));
  console.log("evalState", evalStack(computation, stack0));
  console.log("execState", execStack(computation, stack0));
  console.groupEnd();
})();
</script>



Done
----
If you're still with me, then let me tell you that this is how the state monad
could look like in JavaScript. It probably doesn't look that readable, compared
to a similar Haskell version, but it's the most I can get out of JavaScript today.

A monad is a pretty abstract concept because it specifies little about what you
have to write. Mainly, it says that you need to design a function which will
take some arguments (the state in the case of the state monad), and two additional
functions: `result` and `bind`. The former will act as a factory for the function
you just designed. The latter we'll be responsible for exposing just enough details
about your monad to the outside world, and also perform some boring stuff like
passing state around. Exposing is done by means of a continuation function that
will take the value that the monad computes. Everything that is internal to the
monad will be kept internal. Just like in object-oriented programming. And it's
even possible to have monadic getters/setters for the those internals.

Just for the record, here's how the `computation` function would look like in
Haskell.

~~~ {.haskell}
computation = do push 4
                 push 5
                 a <- pop
                 b <- pop
                 return $ (show a) ++ " : " ++ (show b)
~~~

The main reason the Haskell version looks better is because Haskell has built-in
syntactic support for monads in the form of the `do` notation. `do` notation is
just sugar for the following version, which still looks better than the JavaScript
one. Haskell, having support for operator definitions and terse lambda expressions
allows for more readable, in my opinion, implementation of monads.

~~~ {.haskell}
computation = push 4 >>= \_ ->
              push 5 >>= \_ ->
              pop    >>= \a ->
              pop    >>= \b ->
              return $ (show a) ++ " : " ++ (show b)
~~~

What I called `bind` in JavaScript is `>>=` in Haskell, and what I called
`result` in JavaScript is `return` in Haskell. Yes, `return` in Haskell is a
function, not a keyword. Other times, `return` is named `unit`. Brian Marick
called `>>=` a decider in his [videos about monads in Clojure][2]. The patcher
was of course `return`.



Some JavaScript Sugar
---------------------
It turns out there's a better way to do monadic computations in JavaScript using
a little utility function called `sequence`. Thanks to JavaScript's dynamic
nature, `sequence` can take a variable number of arguments that represent the
monadic actions it must perform in sequence, save for the final argument which
is a callback that contains the computation over the result of the monadic actions.
The callback is called with all the non-`undefined` results of the monadic actions.

~~~ {.javascript}
var sequence = function (/* monadicActions..., final */) {
  var args           = [].slice.call(arguments);
  var monadicActions = args.slice(0, -1);
  var finalResult    = args.slice(-1)[0];

  return function (stack) {
    var initialState = { values: [], stack: stack };

    var state = monadicActions.reduce(function (state, action) {
      var result = action(state.stack);
      var values = state.values.concat(result.value);
      var stack  = result.stack;

      return { values: values, stack: stack };
    }, initialState);

    var values = state.values.filter(function (value) {
      return value !== undefined;
    });

    return continuation.apply(this, values)(state.stack);
  };
};

var computation = sequence(
  push(4), // <- programmable commas :)
  push(5),
  pop(),
  pop(),

  function (pop1, pop2) {
    return result(pop1 + " : " + pop2);
  }
);

var initialStack = [];
var result = computation(initialStack); // "5 : 4"
~~~

The authors of [Real World Haskell][3] compared monads to a [programmable semicolon][4].
In this case, I can say we have programmable commas, because that's what I used
when calling `sequence` to separate monadic actions.

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackAction, continuation) {
    return function (stack) {
      var result = stackAction(stack);
      return continuation(result.value)(result.stack);
    };
  };

  var result = function (value) {
    return function (stack) {
      return { value: value, stack: stack };
    };
  };

  var sequence = function (/* monadicActions, final */) {
    var args           = [].slice.call(arguments);
    var monadicActions = args.slice(0, -1);
    var continuation  = args.slice(-1)[0];

    return function (stack) {
      var initialState = { values: [], stack: stack };

      var state = monadicActions.reduce(function (state, action) {
        var result = action(state.stack);
        var values = state.values.concat(result.value);
        var stack  = result.stack;

        return { values: values, stack: stack };
      }, initialState);

      var values = state.values.filter(function (value) {
        return value !== undefined;
      });

      return continuation.apply(this, values)(state.stack);
    };
  };

  var computation = sequence(
    push(4),
    push(5),
    pop(),
    pop(),

    function (pop1, pop2) {
      return result(pop1 + " : " + pop2);
    }
  );

  var initialStack = [];

  console.group("The `sequence` utility");
  console.log(computation(initialStack));
  console.groupEnd();
})();
</script>



Monads As Suspended Computations
--------------------------------
You'll often see monads being called computations. In the beginning I didn't
understand why. You might say because they compute stuff, but... nobody says
"monads compute something", they actually say "monads are computations".
I finally understood (or I think I did) what that means after I finished an early
draft of this article. All that chaining of monadic actions and values does not
actually compute anything until you tell it to. It's all a big chain of partially
applied functions, which represent a suspended computation that will finally be
triggered by calling it with the initial state. Again, here's this snippet.


~~~ {.javascript}
var computation = sequence(
  push(4),
  push(5),
  pop(),
  pop(),

  function (pop1, pop2) {
    return result(pop1 + " : " + pop2);
  }
);
~~~

Does it compute anything when it is evaluated? No. You have to trigger the
computation with `runStack`, `evalStack`, or `execStack`.

~~~ {.javascript}
var initialStack = [];
evalStack(computation, initialStack);
~~~

It looks like the `push` and `pop` functions act on some global value, whereas
they in fact are always awaiting for that value to come. It's almost like in OOP
where `this` is the context of the computation. In our case though, `this` is
implemented by means of currying and partial application, it also points to a
new context in each expression. And, if in OO context is said to be implicit,
then by using monads you make it even more implicit (if there even is such a
thing).

The advantage of monads (and functional programming in general) is that you get
highly composable building blocks. And it's all because of function currying.
Each time two monadic actions are chained, a new function is created which awaits
to be run.

~~~ {.javascript}
var computation1 = sequence(
  push(4),
  push(5),
  pop(),
  pop(),

  function (pop1, pop2) {
    return result(pop1 + " : " + pop2);
  }
);

var computation2 = sequence(
  push(2),
  push(3),
  pop(),
  pop(),

  function (pop1, pop2) {
    return result(pop1 + " : " + pop2);
  }
);

var composed = sequence(
  computation1,
  computation2,

  function (a, b) {
    return result(a + " : " + b);
  }
);

console.log( evalStack(composed, []) ); // "5 : 4 : 3 : 2"
~~~

<script>
(function () {
  var push = function (element) {
    return function (stack) {
      var value = undefined;
      var newStack = [element].concat(stack);

      return { value: value, stack: newStack };
    };
  };

  var pop = function () {
    return function (stack) {
      var value = stack[0];
      var newStack = stack.slice(1);

      return { value: value, stack: newStack };
    };
  };

  var bind = function (stackAction, continuation) {
    return function (stack) {
      var result = stackAction(stack);
      return continuation(result.value)(result.stack);
    };
  };

  var result = function (value) {
    return function (stack) {
      return { value: value, stack: stack };
    };
  };
  
  var evalStack = function (stackOperation, initialStack) {
    return stackOperation(initialStack).value;
  };

  var sequence = function (/* monadicActions, final */) {
    var args           = [].slice.call(arguments);
    var monadicActions = args.slice(0, -1);
    var continuation  = args.slice(-1)[0];

    return function (stack) {
      var initialState = { values: [], stack: stack };

      var state = monadicActions.reduce(function (state, action) {
        var result = action(state.stack);
        var values = state.values.concat(result.value);
        var stack  = result.stack;

        return { values: values, stack: stack };
      }, initialState);

      var values = state.values.filter(function (value) {
        return value !== undefined;
      });

      return continuation.apply(this, values)(state.stack);
    };
  };

  var computation1 = sequence(
    push(4),
    push(5),
    pop(),
    pop(),

    function (pop1, pop2) {
      return result(pop1 + " : " + pop2);
    }
  );

  var computation2 = sequence(
    push(2),
    push(3),
    pop(),
    pop(),

    function (pop1, pop2) {
      return result(pop1 + " : " + pop2);
    }
  );

  var composed = sequence(
    computation1,
    computation2,

    function (a, b) {
      return result(a + " : " + b);
    }
  );

  console.group("Composability");
  console.log( evalStack(composed, []) );
  console.groupEnd();
})();
</script>

This may seem useless for performing stack operations, but when designing a
library of monadic parser combinators for example, this gets very handy. It
allows the author of the library to provide just a handful of "primitive"
functions on his Parser monad, and then, the user of the library is able to mix
and match those primitives as he sees fit, ultimately ending up with an embedded
domain specific language (<abbr title="Embedded Domain Specific Language">EDSL</abbr>).



The End
-------
Well, I hope you found this article useful. Writing it definitely helped me
having a better understanding of monads.



References
----------
- Books
    - [Programming in Haskell][5]
    - [Learn You a Haskell For Great Good!][6]
    - [Real World Haskell][3]

- Articles and Papers
    - [A Schemer's Introduction to Monads][7]
    - [Monadic Parsing in Haskell][8]
    - [Monadic Parser Combinators][9]
    - [Monads in Python][10]

- Videos
    - [The Quick Essence of Functional Programming][11]
    - [Monad Tutorial in Clojure, Part 1][12]
    - [Monad Tutorial in Clojure, Part 2][13]
    - [Monad Tutorial in Clojure, Part 3][14]
    - [Monad Tutorial in Clojure, Part 4][15]


[1]: /posts/2010-12-01-deriving-the-y-combinator-in-7-easy-steps.html
[2]: #references
[3]: http://book.realworldhaskell.org/
[4]: http://book.realworldhaskell.org/read/monads.html#id642960
[5]: http://www.cs.nott.ac.uk/~gmh/book.html
[6]: http://learnyouahaskell.com/
[7]: http://www.ccs.neu.edu/home/dherman/research/tutorials/monads-for-schemers.txt
[8]: http://www.cs.nott.ac.uk/~gmh/bib.html#pearl
[9]: http://www.cs.nott.ac.uk/~gmh/bib.html#monparsing
[10]: http://www.valuedlessons.com/2008/01/monads-in-python-with-nice-syntax.html
[11]: http://channel9.msdn.com/Shows/Going+Deep/C9-Lectures-Dr-Ralf-Lmmel-AFP-The-Quick-Essence-of-Functional-Programming
[12]: http://vimeo.com/20717301
[13]: http://vimeo.com/20798376
[14]: http://vimeo.com/20963938
[15]: http://vimeo.com/21307543
[16]: http://vimeo.com/23125621
[17]: https://gist.github.com/936519
[18]: https://gist.github.com/936695
