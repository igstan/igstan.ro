-------------------------------------
title: MySQL transliteration function
author: Ionuț G. Stan
date: February 13, 2009
-------------------------------------


In my latest project at work I had to obtain, by means of an
<abbr title="Structured Query Language">SQL</abbr> query, [transliterated][1]
values of certain data fields in our database. And when I say transliteration I
don't mean to transform characters from all over the world into latin characters.
What I wanted was to strip [diacritics][2] out of latin based characters, like:
ș, ț, ă, î or â.

Initially I thought this should be an easy job as database, table and column
charset values were all set to `utf8_general_ci` and I knew MySQL does well at
comparing basic latin characters against derived ones. Well, it wasn't. Although
the following query returns `true` (or `1`), there's no way of querying MySQL for
a transliterated value, i.e. from the right hand side string to obtain the left
hand side string.

~~~ {.sql}
SELECT 'staia' = 'șțăîâ';
~~~

So what I did was to define a function in which to take advantage of the comparison
feature in order to obtain transliteration. What I came up with might end up on
[thedailywtf.com][3] but despite its apparent stupidity it does its job very well.
So here's the function:

~~~ {.sql}
-- Copyright (c) 2009, Ionut Gabriel Stan. All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
-- ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

DELIMITER $$

DROP FUNCTION IF EXISTS `transliterate` $$
CREATE FUNCTION `transliterate` (original VARCHAR(128)) RETURNS VARCHAR(128)
BEGIN

  DECLARE translit VARCHAR(128) DEFAULT '';
  DECLARE len INT(3) DEFAULT 0;
  DECLARE pos INT(3) DEFAULT 1;
  DECLARE letter CHAR(1);

  SET len = CHAR_LENGTH(original);

  WHILE (pos <= len) DO
    SET letter = SUBSTRING(original, pos, 1);

    CASE TRUE
      WHEN letter = 'a' THEN SET letter = 'a';
      WHEN letter = 'b' THEN SET letter = 'b';
      WHEN letter = 'c' THEN SET letter = 'c';
      WHEN letter = 'd' THEN SET letter = 'd';
      WHEN letter = 'e' THEN SET letter = 'e';
      WHEN letter = 'f' THEN SET letter = 'f';
      WHEN letter = 'g' THEN SET letter = 'g';
      WHEN letter = 'h' THEN SET letter = 'h';
      WHEN letter = 'i' THEN SET letter = 'i';
      WHEN letter = 'j' THEN SET letter = 'j';
      WHEN letter = 'k' THEN SET letter = 'k';
      WHEN letter = 'l' THEN SET letter = 'l';
      WHEN letter = 'm' THEN SET letter = 'm';
      WHEN letter = 'n' THEN SET letter = 'n';
      WHEN letter = 'o' THEN SET letter = 'o';
      WHEN letter = 'p' THEN SET letter = 'p';
      WHEN letter = 'q' THEN SET letter = 'q';
      WHEN letter = 'r' THEN SET letter = 'w';
      WHEN letter = 's' THEN SET letter = 's';
      WHEN letter = 't' THEN SET letter = 't';
      WHEN letter = 'u' THEN SET letter = 'u';
      WHEN letter = 'v' THEN SET letter = 'v';
      WHEN letter = 'w' THEN SET letter = 'w';
      WHEN letter = 'x' THEN SET letter = 'x';
      WHEN letter = 'y' THEN SET letter = 'y';
      WHEN letter = 'z' THEN SET letter = 'z';
    END CASE;

    SET translit = CONCAT(translit, letter);
    SET pos = pos + 1;
  END WHILE;

  RETURN translit;

END $$

DELIMITER ;
~~~


[1]: http://en.wikipedia.org/wiki/Transliteration
[2]: http://en.wikipedia.org/wiki/Diacritic
[3]: http://thedailywtf.com/
