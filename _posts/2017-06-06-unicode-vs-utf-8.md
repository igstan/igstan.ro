---
title: Unicode vs UTF-8
author: Ionuț G. Stan
date: June 06, 2017
---

I couldn't sleep and my mind wandered around, finally reaching a place where I
would explain Unicode to an undefined audience. It was almost an hour of laying
purposeless in bed and the explanation seemed rather nice and short, so I
thought I'd get out of bed and put it down here.

## Unicode vs UTF-8

<img src="/files/images/unicode-vs-utf-8.png" alt="Google Search auto-suggests unicode vs utf-8." width="670">

There was a time when I had no idea what Unicode actually was. All I knew was
that it's some sort of technology that makes computers understand how to display
my first name, Ionuț. I also heard about UTF-8, which presumably did the same
thing, but better. Naturally, I wondered what was the difference between them. I
remember reading Joel Spolsky's article [The Absolute Minimum Every Software
Developer Absolutely, Positively Must Know About Unicode and Character Sets][0],
but for some reason it didn't click. This is my take on explaining the
difference, 14 years later.

## Charsets and Code Points

Imagine that we're gathering all the world's written chracters that exist or
have ever existed. They would be Latin characters, Arabic, Japanese, emojis or
even [Klingon][1] ones. Next, we put all of them in a single big ordered list.
By doing this we implicitly assign each character a number — its index in that
list. This very big list is called a <strong>charset</strong> and the indeces
are called <strong>code points</strong>. In other words, a charset is a mapping
from code points to characters.

The next step is to get all software manufacturers to use this charset. Whenever
thay want to accept or output a certain character in their software packages,
they should be representing them in the computer language using the
corresponding code point of our charset, which is just a number.

## Encodings

Computers, however, don't directly understand mathematical numbers. What they
can do is interpret sequences of `1` and `0` as numbers. So we need yet another
standard that puts everyone on agreement on how to represent these numbers in
the binary language understood by a computer. This additional transformation is
called an <strong>encoding</strong>. Put otherwise, an encoding specifies how to
translate code points to sequences of `1` and `0`.

### 32-bit Encoding

Where's the main difficulty with representing numbers in binary format? It's in
determining where to stop reading a sequence of bits and _then_ treat it as a
mathematical number.

We could use 8 bits, i.e., a byte. However, with 8 bits we can only represent
256 numbers. That's clearly not enough for all the characters we've gathered, we
have more than just 256. What next?

We can use 16 bits in a row to represent a number. That's a little better, we
can now represent numbers up to 65535. Should it be enough? Well, it accomodates
all the characters we've gathered so far and it allows some future ones. But
just to be safe, let's use 32 bits in a row to represent numbers. This will
allow our charset to acommodate as many as 4,294,967,296 characters. Done deal,
each character will be represented in the computer code using 32 bits for each
character.

### 16-bit Encoding

Are we done yet? Not quite, because the software manufacturers will notice that
their users will mostly use characters that are assigned numbers less than 128,
which means they could fit on 7 bits. Having them represented on 32 bits means a
lot of wasted resources. So we come up with a better encoding, one that requires
just 16 bits to represent a number.

As we've seen above, 16 bits allow us to represent numbers up to 65535. What
shall we do for numbers greater than this one? We can apply a clever little
trick. We can reserve a few 16-bit combinations which used alone don't encode
any code point, but when seen in pairs are treated as 32-bit numbers. We decide
to reserve 2048 such 16-bit combinations, where 1024 of them can only appear as
the first component of the pair and the other 1024 can only appear as the second
component. These are called <strong>surrogate pairs</strong>.

This trick means that we'll be able to represent `65536 - 2048 = 63488`
characters using 16-bit numbers and an additional `1024 * 1024 = 1048576`
characters using surrogate pairs. It all totals up to 1,112,064 characters. This
is less than the 32-bit encoding, but we'll decide it's a good trade-off and
move on. In addition, we'll also limit the maximum number representable in the
32-bit encoding to that of the 16-bit encoding, to keep things consistent. We'll
call the first encoding <strong>UTF-32</strong> and the second one
<strong>UTF-16</strong>.

### 8-bit Encoding

Finally, we figure out there's an even better way to encode code points less
than 128 using just 8 bits. So we come up with an encoding that uses an
increasing number of 8-bit blocks, i.e., bytes, as we need to represent bigger
numbers. This is also called a variable-length encoding because the number of
bytes used to represent a character varies.

The main idea behind this encoding is to add a mark at the beginning of the
first byte that says how many bytes the sequence is composed of.

```
 Code Point Range | Applicable Bit Sequence
------------------|---------------------------------------
 0 - 127          | 0xxxxxxx
 128 - 2047       | 110xxxxx  10xxxxxx
 2048 - 65535     | 1110xxxx  10xxxxxx  10xxxxxx
 65536 - 1114111  | 11110xxx  10xxxxxx  10xxxxxx  10xxxxxx
```

So, if we want to represent a number between 0 and 127 we can just output a `0`
bit followed by the 7 bits that encode the number. For numbers between 128 and
2047 we need two bytes. The first one starts with the `110` bit sequence, while
the second with the `10` bit sequence. The `x` characters can be used to fill in
the bits of the number we want to represent. Similarly for the other two cases.
We'll call this encoding <strong>UTF-8</strong>.

## Quick Glossary

To summarize all the things we've discussed so far, here's a quick list of concepts:

  - <strong>charset</strong>: a mapping from numbers to characters;
  - <strong>Unicode</strong>: the best such charset we have today;
  - <strong>code point</strong>: an index into the charset;
  - <strong>encoding</strong>: a recipe describing how to represent code points
    as computer bits;
  - <strong>UTF-32</strong>: encoding where each code point is represented using
    32-bit sequences;
  - <strong>UTF-16</strong>: encoding where code points are represented using
    16-bit sequences;
  - <strong>UTF-16 surrogate pairs</strong>: pairs of 16-bit sequences that are
    used to encode code points that don't fit in a single 16-bit sequence. There
    are only 1024 surrogate pairs, i.e., 2048 such 16-bit sequences.
  - <strong>UTF-8</strong>: encoding where code points can be represented using
    a variable number of 8-bit sequences, from 1 to a maximum of 4.

## Conclusion

As you've probably understood by now, UTF-8 is just a concrete realization of a
more abstract concept called Unicode, so there's no point in comparing them.

[0]: https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/
[1]: http://www.klingonwiki.net/En/Unicode
