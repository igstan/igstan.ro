---
title: Recursive Computations in Eve
author: Ionuț G. Stan
---

## Understanding the Problem

Let's try to implement this well well-known recursive function in Eve. It is
defined by two cases, as demonstrated by the following Haskell implementation:

```haskell
factorial 0 = 1
factorial n = n * factorial (n - 1)
```

What is implicit in the above piece of code is the presence of a stack. A hidden
stack data structure is used by the runtime to manage intermediate results for
us. We don't have this facility in Even, so what can we do?

All that Eve offers us are databases, so we'll make use of that. We'll create a
special @`factorial` database within which our `factorial` function can store
and match whatever it pleases.

## Databases as Message Queues

An Eve database is akin to a message queue in an actor system, while a
search/bind pair can be seen as the receive function of an actor.

## Base Case

```
search
  r = [#factorial n: 0]

bind
  r.return := 1
```

## Recursive Case

### Send

```
search
  r = [#factorial n > 0]
  a = r.n - 1

bind
  [#factorial n: r.n - 1]
  [#log info: "factorial {{a}} = ???"]
```

### Recv

```
search
  r = [#factorial n]
  p = [#factorial n: r.n - 1 return]

bind
  r.return := r.n * return
  [#log info: "factorial {{p.n}} = {{return}}"]
```

## Usage

```
commit
  [#factorial n: 7]
```

```
search
  r = [#factorial n: 7 return]

bind
  [#log info: "factorial {{r.n}} = {{return}}"]
```

## Logging

```
search
  [#log info]

bind @browser
  [#div text: info]
```
