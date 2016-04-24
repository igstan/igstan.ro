--------------------------------------------------------------------------------
title: On Designing APIs as EDSLs
author: Ionuț G. Stan
date: May 20, 2014
--------------------------------------------------------------------------------

Before reading any further, please note that I'm really making an important
distinction between DSL and EDSL in this post. An EDSL is, indeed, embedded in a
host language and uses the host language syntax for its own purposes. The only
thing an EDSL adds to the table is a particular semantics for a particular domain.
A DSL is language "outside" the host language. For example, SQL is a DSL for
querying relational data, while X API is an EDSL.

Actually, the main thesis of this blog post is that any API we write forms an
EDSL, and the more we try to formalize it, the better quality it has.

Designing EDSLs using this method is probably conducive to functional-style
APIs, but not necessarily.

Ever since I read this blog post on how to map the BNF grammar of a DSL to
an actual implementation (in Java) of that DSL — thus ending up with an EDSL — I
couldn't stop thinking that we should be writing formal grammars for all the
EDSLs we design. Countless times I've used some library which claimed to provide
an EDSL for doing X, but trying to use it was a royal pain in the ass. Why was
that? Because the authors forgot about the L in EDSL. The library didn't provide
a **language**, but a blob of methods with weird names, either too concise or
opaque symbols.

 - using EBNF extension points (`? comment ?`) as a means of plugging in
   host-language features. For example: `"ENUM(" ? Function1[String, String] ? ")"`.

```scala
// EBNF grammar for this DSL:
//
// field       = "DEF FIELD" name (description | transform) ;
// description = "TYPE" type "SUPPORTS" features [rename] ;
// type        = "BOOL" | "STRING" | "INT" | "DATE" | enum ;
// enum        = c ;
// features    = "(" feature { "," feature } ")";
// feature     = "EQ" | "SORT" | "COMP" ;
// rename      = "RENAME" name ;
// name        = ? String ? ;
// transform   = "TRANSFORM {" ? Function1[String, Query] ? "}";
//
```
