---
title: Dynamic Time-Shifted Observables with Monix
author: Ionuț G. Stan
---

Someone recently asked on the Monix Gitter channel how to devise an `Observable` whose emitted items are separated in time by a dynamic delay, rather than a fixed delay. Here, dynamic simply means that the value is only know at runtime, not at compile-time. I will try here to show a solution to this problem.

## Prelude

For the rest of this post, I'll assume the following imports are in scope:

```scala
import scala.concurrent._, duration._
import monix.reactive._
import monix.execution._, Scheduler.Implicits.global
```

In addition, we'll also have access to the following log method, which will help with observing emission times:

```scala
def log(msg: Any): Unit =
  println(s"${java.time.LocalTime.now()}: $msg")
```

## Time-Shifted Observables

Monix provides a few combinators to create time-shifted observables. A time-shifted observable is one where the times of item emission are delayed by some means. For example, the following ordinary cold observable will emit all its items almost immediately:

```scala
scala> Observable(1, 2, 3, 4).foreach(log)
13:04:13.414: 1
13:04:13.416: 2
13:04:13.416: 3
13:04:13.416: 4
```

Whereas the following, which will wait 1 second before emitting the subsequent element, is a time-shifted observable:

```scala
scala> Observable(1, 2, 3, 4).delayOnNext(1.second).foreach(log)
13:04:45.068: 1
13:04:46.073: 2
13:04:47.077: 3
13:04:48.082: 4
```

The last one example uses a fixed delay of `1.second` to space in time the items. But what if we want this value to be supplied by the user at runtime? It's easy if the `Observable` will be created as a consequence of the user action, but if the `Observable` already exists, i.e., someone has already subscribed to it, then things aren't quite straightforward. There's no way to go back and readjust this delay value.

## Dynamic Time-Shifting

I think the key to understanding the solution to this problem is to see the user actions as an observable. The user is an observable and our program its observer. For this particular case, the user is an observable of delays:

```scala
def userDelays: Observable[FiniteDuration] = ???
```

With that in mind, we can take a glance over Monix's list of combinators and see whether it provides one where the source observable emits items only when some other observable will emit one. Indeed, there is one called `delayOnNextBySelector` having the following signature and doc comment:

```scala
/** Returns an Observable that emits the items emitted by the source
  * Observable shifted forward in time.
  *
  * This variant of `delay` sets its delay duration on a per-item
  * basis by passing each item from the source Observable into a
  * function that returns an Observable and then monitoring those
  * Observables. When any such Observable emits an item or
  * completes, the Observable returned by delay emits the associated
  * item.
  *
  * @param selector is a function that returns an Observable for
  *        each item emitted by the source Observable, which is then
  *        used to delay the emission of that item by the resulting
  *        Observable until the Observable returned from `selector`
  *        emits an item
  * @return the source Observable shifted in time by
  *         the specified delay
  */
def delayOnNextBySelector[B](selector: A => Observable[B]): Observable[A]
```

This combinator exposes a pluggable way of delaying each item by an amount of time that can be entirely tailored to that particular item. We won't need that full power here, but it might be what we're looking for. Let's first reimplement `delayOnNext` in terms of `delayOnNextBySelector`.

```scala
scala> val delay = Observable.now(()).delaySubscription(1.second)
scala> val delayLog = delay.doOnTerminate(_ => log("Delay terminated."))
scala> Observable(1, 2, 3, 4).delayOnNextBySelector(_ => delayLog).foreach(log)
13:38:31.487: 1
13:38:31.488: Delay terminated.
13:38:32.493: 2
13:38:32.493: Delay terminated.
13:38:33.495: 3
13:38:33.495: Delay terminated.
13:38:34.500: 4
13:38:34.500: Delay terminated.
```

I've added some logging regarding termination to see when the selector observables are canceled. It seems ther're canceled as soon as they emit the first item. But the values are emitted as we wanted them to be, once a second.

This is still a static configuration, though. The subscription delay of the `delay` observable is known at compile time. Whereas we want to use the ones provided by the user. That should be simple, we just map over user observable and produce delayed observables. The result is an observable of observables, so we better flatten it:

```
val delays: Observable[Unit] = userDelays.flatMap { duration =>
  Observable.now(()).delaySubscription(duration)
}
```

So, what this does is that whenever the user will emit a new duration, we'll transform that to an observable whose subscription is delayed by the user-supplied time.


```scala
// A stubbed user.
//
// The user starts by saying they want items emitted every one second. After
// 2 seconds, they change their mind and decide they want items emitted every
// 2 seconds. Similarly for the
scala> val userDelays = Observable(
  Observable.now(1.second),
  Observable.now(2.seconds).delaySubscription(2.seconds)
).flatten

scala> val delays = userDelays.flatMap { duration =>
  Observable.now(()).delaySubscription(duration)
}

scala> val delayLog = delays.doOnTerminate(_ => log("Delay terminated."))
scala> Observable(1, 2, 3, 4).delayOnNextBySelector(_ => delayLog).foreach(log)
```

However, this doesn't behave as we'd expect. All the items are emitted 1 second apart, whereas we'd have expected the third and fourth to be emitted 2 seconds apart. What's wrong? The clue is in the "Delay terminated." log message. The selector we pass to `delayOnNextBySelector` will resubscribe to `delayLog` each time it's called and `delayLog` will reinitialize it's delayed subscription. It's what's called a cold observable. We need a hot one, one that's shared between all invocations of our selector. And the simplest way to do that is to call `publish` on `delayLog` and then `connect` to it.


```scala
import scala.concurrent.duration._
import monix.execution.Scheduler.Implicits.global
import monix.reactive.Observable
import monix.reactive.subjects.ConcurrentSubject

object Playground {
  def main(args: Array[String]): Unit = {
    val defaultDelay = 2.seconds

    // Default delay before the client updates the delay, if ever.
    val client = ConcurrentSubject.behavior(defaultDelay)

    val delays = client
      .switchMap { duration =>
        // Whenever the client sends a new delay value, we switch to an
        // observable that emits items at that rate. This will dictate
        // the cadence of the `server` Observable below.
        log(s"Ticking every $duration from now on.")
        Observable.interval(duration)
      }
      // We need to make this Observable hot, otherwise the delay selector
      // in `server` will only ever see the first value, which is `defaultDelay`.
      .publish

    val server = Observable.repeat("element")
      // Emit our item whenever `delays` emits a new item.
      .delayOnNextBySelector(_ => delays)
      // Debugging stuff.
      .doOnNext { item =>
        log(s"Emitted item: $item.")
      }
      .doOnEarlyStop { () =>
        log("Server terminated.")
      }

    // Now, let's test the machinery above.
    val delaysCancelable = delays.connect()
    val serverCancelable = server.subscribe()

    // Set a new delay duration after 10 seconds.
    global.scheduleOnce(10.seconds) {
      log(s"Setting delay to 4 seconds.")
      client.onNext(4.seconds)
    }

    // Reset the delay duration after 30 seconds.
    global.scheduleOnce(30.seconds) {
      log(s"Setting to 2 seconds.")
      client.onNext(2.seconds)
    }

    // Shut down everything.
    global.scheduleOnce(60.seconds) {
      client.onComplete()
      delaysCancelable.cancel()
      serverCancelable.cancel()
    }
  }

  def log(msg: Any): Unit =
    println(s"${java.time.LocalTime.now()}: $msg")
}
```
