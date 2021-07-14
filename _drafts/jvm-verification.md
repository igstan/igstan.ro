---
title: JVM Bytecode Verification
author: Ionuț G. Stan
---

I'll briefly describe the process of bytecode verification that the JVM performs during the loading of .class files.

## Motivation

Why was verification needed?

## Complications

There's a hierarchy of verification types that induces a notion of subtyping. Store and load instructions need to check subtyping conformance and this requires loading external classes into the system. I'm hoping to avoid this somehow, as it requires the side-effect of reading files form disk. In addition, it means that I might need to write a parser for .class files and a JAR (which are ZIP archives) reader.
