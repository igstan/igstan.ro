---
title: Why Int isn't a Fractional
author: Ionuț G. Stan
---

```
scala> implicitly[Fractional[Double]]
res1: Fractional[Double] = scala.math.Numeric$DoubleIsFractional$@3a2d3909

scala> implicitly[Fractional[Int]]
<console>:12: error: could not find implicit value for parameter e: Fractional[Int]
       implicitly[Fractional[Int]]
                 ^
```

Something to do with associativity or something.
