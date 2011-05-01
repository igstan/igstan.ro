----------------------------------------
title: Monads are Suspended Computations
author: Ionuț G. Stan
date: January 03, 2011
----------------------------------------


Step 1
------

~~~ {.javascript}
(function() {
// Functional style stack with explicit handling of state.

var push = function(element, stack) {
    var newElements = [element].concat(stack.elements);
    var newSize     = stack.size + 1;

    return {
        elements : newElements,
        size     : newSize
    };
};

var pop = function(stack) {
    // The `slice` method of the Array object does not mutate the object on
    // which is called, it returns a new Array object. That's why this version
    // is functional.
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    // Return both the popped element and the new state that represents the
    // resulted stack.
    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};


// For the purpose of this article, this object is similar to a struct in C.
// I use it only for storing data, and avoid calling any method inherited from
// Object.prototype.
var stack0 = {
    elements : [1, 2, 3],
    size     : 3
};

// As you can see, some tedious work is required here in order to pass the
// state argument from function to function. Good engineering practices demand
// this be abstracted away. And that's what I'm going to do.
var stack1            = push(4, stack0);
var stack2            = push(5, stack1);
var [result0, stack3] = pop(stack2);
var [result1, stack4] = pop(stack3);

console.group("Step 1");
console.log(result0); // 5
console.log(result1); // 4
console.groupEnd();

})();
~~~

Step 2
------

~~~ {.javascript}
(function() {

var push = function(element, stack) {
    var newElements = [element].concat(stack.elements);
    var newSize     = stack.size + 1;

    return [
        undefined,
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var stack0 = {
    elements : [1, 2, 3],
    size     : 3
};

var [result0, stack1] = push(4, stack0);
var [result1, stack2] = push(5, stack1);
var [result2, stack3] = pop(stack2);
var [result3, stack4] = pop(stack3);

console.group("Step 2");
console.log(result2);
console.log(result3);
console.groupEnd();

})();
~~~

Step 3
------

~~~ {.javascript}
// The Lambda Calculus Artifice
// replacing variables with arguments and parameters
//
// This is probably pretty hard to understand at a first sight, but... the
// reason to apply this transformation is because it's pretty hard to
// abstract over variable, whereas abstracting over functions can be done
// with higher-order functions.
(function() {

var push = function(element, stack) {
    var newElements = [element].concat(stack.elements);
    var newSize     = stack.size + 1;

    return [
        undefined,
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};


var stack0 = {
    elements : [1, 2, 3],
    size     : 3
};

(function([result0, stack1]) {
    (function([result1, stack2]) {
        (function([result2, stack3]) {
            (function([result3, stack4]) {

                console.group("Step 3 - lambda calculus style variables");
                console.log(result2);
                console.log(result3);
                console.groupEnd();

            })( pop(stack3) );
        })( pop(stack2) );
    })( push(5, stack1) );
})( push(4, stack0) );

})();
~~~


Step 4
------

~~~ {.javascript}
(function() {

var push = function(element) {
    return function(stack) {
        var newElements = [element].concat(stack.elements);
        var newSize     = stack.size + 1;

        return [
            undefined,
            {
                elements : newElements,
                size     : newSize
            }
        ];
    };
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var bind = function(next, action, stack) {
    var [result, newStack] = action(stack);
    next(result, newStack);
};

var stack0 = {
    elements : [1, 2, 3],
    size     : 3
};

bind(function(result0, stack1) {
    bind(function(result1, stack2) {
        bind(function(result2, stack3) {
            bind(function(result3, stack4) {

                console.group("Step 4");
                console.log(result2);
                console.log(result3);
                console.groupEnd();

            }, pop, stack3);
        }, pop, stack2);
    }, push(5), stack1);
}, push(4), stack0);

})();
~~~


Step 5
------

~~~ {.javascript}
(function() {

var push = function(element) {
    return function(stack) {
        var newElements = [element].concat(stack.elements);
        var newSize     = stack.size + 1;

        return [
            undefined,
            {
                elements : newElements,
                size     : newSize
            }
        ];
    };
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var bind = function(next, action, stack) {
    return function(stack) {
        var [result, newStack] = action(stack);
        next(result, newStack);
    };
};

var stack0 = {
    elements : [1, 2, 3],
    size     : 3
};

bind(function(result0, stack1) {
    bind(function(result1, stack2) {
        bind(function(result2, stack3) {
            bind(function(result3, stack4) {

                console.group("Step 5");
                console.log(result2);
                console.log(result3);
                console.groupEnd();

            }, pop)(stack3);
        }, pop)(stack2);
    }, push(5))(stack1);
}, push(4))(stack0);

})();
~~~


Step 6
------

~~~ {.javascript}
(function() {

var push = function(element) {
    return function(stack) {
        var newElements = [element].concat(stack.elements);
        var newSize     = stack.size + 1;

        return [
            undefined,
            {
                elements : newElements,
                size     : newSize
            }
        ];
    };
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var bind = function(next, action, stack) {
    return function(stack) {
        var [result, newStack] = action(stack);
        return next(result)(newStack);
    };
};

var sameStack = function(stack) {
    return stack;
};

var computation = bind(function(result0) {
    return bind(function(result1) {
        return bind(function(result2) {
            return bind(function(result3) {

                console.group("Step 6");
                console.log(result2);
                console.log(result3);
                console.groupEnd();

                return sameStack;

            }, pop);
        }, pop);
    }, push(5));
}, push(4));

var initialStack = {
    elements : [1, 2, 3],
    size     : 3
};

computation(initialStack);

})();
~~~


Step 7
------

~~~ {.javascript}
(function() {

var push = function(element) {
    return function(stack) {
        var newElements = [element].concat(stack.elements);
        var newSize     = stack.size + 1;

        return [
            undefined,
            {
                elements : newElements,
                size     : newSize
            }
        ];
    };
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var bind = function(action, next) {
    return function(stack) {
        var [result, newStack] = action(stack);
        return next(result)(newStack);
    };
};

var sameStack = function(stack) {
    return stack;
};

var computation = bind(push(4), function() {
    return bind(push(5), function() {
        return bind(pop, function(result2) {
            return bind(pop, function(result3) {

                console.group("Step 7");
                console.log(result2);
                console.log(result3);
                console.groupEnd();

                return sameStack;

            });
        });
    });
});

var initialStack = {
    elements : [1, 2, 3],
    size     : 3
};

computation(initialStack);

})();
~~~


Step 7
------

~~~ {.javascript}
(function() {

var push = function(element) {
    return function(stack) {
        var newElements = [element].concat(stack.elements);
        var newSize     = stack.size + 1;

        return [
            undefined,
            {
                elements : newElements,
                size     : newSize
            }
        ];
    };
};

var pop = function(stack) {
    var newElements = stack.elements.slice(1);
    var newSize     = stack.size - 1;

    return [
        stack.elements[0],
        {
            elements : newElements,
            size     : newSize
        }
    ];
};

var sequence = function(/* actions..., next */) {
    var args    = Array.prototype.slice.call(arguments);
    var next    = args.pop();
    var actions = args;

    return function(stack) {
        var results  = [];
        var newStack = stack;
        var result;

        actions.forEach(function(action) {
            [result, newStack] = action(newStack);
            results.push(result);
        });

        return next.apply(this, results)(newStack);
    };
};

var sameStack = function(stack) {
    return stack;
};

var computation = sequence(
    push(4),
    push(5),
    pop,
    pop,

    function(_, _, result2, result3) {
        console.group("Step 8");
        console.log(result2);
        console.log(result3);
        console.groupEnd();

        return sameStack;
    }
);

var initialStack = {
    elements : [1, 2, 3],
    size     : 3
};

computation(initialStack);

})();
~~~
