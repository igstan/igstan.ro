---
title: A Forth-Like EDSL in Scala
author: Ionuț G. Stan
---

```
sealed trait Ops

object Ops {
  case class GenerateS3Key extends Ops
  case class InsertDynamoRecord extends Ops
  case class GetDynamoRecord extends Ops
  case class WriteContentToS3 extends Ops
  case class ReadContentFromS3 extends Ops
}

type Program[A] = List[A]
val End = Nil

val getPhoto = {
  import Ops._

  GetDynamoRecord ::
  ReadContentFromS3 ::
  End
}
```
