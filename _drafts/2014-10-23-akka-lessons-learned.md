---
title: Akka Lessons Learned
author: Ionuț G. Stan
date: October 23, 2014
---

1. Don't use `BalancingPool` for actors that have identity/state, e.g., RabbitMQ
channels.

2. Different types of failures, i.e. exceptions and `Try`. Failures come in two
flavors, but `Try` isn't supervised.

3. `Future[A]` is actually `Async[Try[A]]`
