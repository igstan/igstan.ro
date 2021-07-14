---
title: Tweetsplaining
author: Ionuț G. Stan
---

```scala
type IO[A] = Free[λ[α ⇒ () ⇒ Throwable ∨ α], A]
type Task[A] = ContT[IO, Unit, Throwable ∨ α]

def lift[A](ioa: IO[A]) = ContT(ioa.flatMap)
```

https://twitter.com/djspiewak/status/852931870820007937
