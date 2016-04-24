---
title: Cross-Compiling GCC for MIPS on Mac OS X
author: Ionuț G. Stan
date: August 26, 2014
---

```
$ wget ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.1/gcc-4.9.1.tar.bz2
$ export PREFIX=/Users/igstan/Desktop/mips-gcc
$ export CC=/usr/local/bin/gcc-4.9
$ export CXX=/usr/local/bin/g++-4.9
$ export CPP=/usr/local/bin/cpp-4.9
$ export LD=/usr/local/bin/gcc-4.9
$ ../gcc-4.9.1/configure --target=mips --prefix=$PREFIX --with-newlib \
   --without-headers --with-gnu-as --with-gnu-ld --disable-shared \
   --enable-languages=c
$ make all-gcc
$ make install-gcc
```

## References

 - http://nerdishbynature.blogspot.ro/2013/01/cross-compiling-gcc-for-mips.html
 - http://www.theairportwiki.com/index.php/Building_a_cross_compile_of_GCC_for_MIPS_on_OS_X
