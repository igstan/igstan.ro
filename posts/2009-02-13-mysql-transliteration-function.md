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

**UPDATE**: I've incorporated [Gabriel Humeniuc's fixes](#comment-183108903)
for preserving the character case, fixed a bug in the MySQL `CONCAT` function
which ignores whitespace characters, and added a special case for the Polish
letter "ł". However the most up-to-date version of this procedure will always
be on GitHub: [https://github.com/igstan/sql-utils/blob/master/transliterate.sql][4].

~~~ {.sql}
-- Copyright (c) 2012, Ionut Gabriel Stan. All rights reserved.
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
CREATE FUNCTION `transliterate` (original VARCHAR(512)) RETURNS VARCHAR(512)
BEGIN

  DECLARE translit VARCHAR(512) DEFAULT '';
  DECLARE len      INT(3)       DEFAULT 0;
  DECLARE pos      INT(3)       DEFAULT 1;
  DECLARE letter   CHAR(1);
  DECLARE is_lower BIT;

  SET len = CHAR_LENGTH(original);

  WHILE (pos <= len) DO
    SET letter   = SUBSTRING(original, pos, 1);
    SET is_lower = IF(LCASE(letter) COLLATE utf8_bin = letter COLLATE utf8_bin, 1, 0);

    CASE TRUE
      WHEN letter = 'a' THEN SET letter = IF(is_lower, 'a', 'A');
      WHEN letter = 'b' THEN SET letter = IF(is_lower, 'b', 'B');
      WHEN letter = 'c' THEN SET letter = IF(is_lower, 'c', 'C');
      WHEN letter = 'd' THEN SET letter = IF(is_lower, 'd', 'D');
      WHEN letter = 'e' THEN SET letter = IF(is_lower, 'e', 'E');
      WHEN letter = 'f' THEN SET letter = IF(is_lower, 'f', 'F');
      WHEN letter = 'g' THEN SET letter = IF(is_lower, 'g', 'G');
      WHEN letter = 'h' THEN SET letter = IF(is_lower, 'h', 'H');
      WHEN letter = 'i' THEN SET letter = IF(is_lower, 'i', 'I');
      WHEN letter = 'j' THEN SET letter = IF(is_lower, 'j', 'J');
      WHEN letter = 'k' THEN SET letter = IF(is_lower, 'k', 'K');
      WHEN letter = 'l' THEN SET letter = IF(is_lower, 'l', 'L');
      WHEN letter = 'ł' THEN SET letter = IF(is_lower, 'l', 'L');
      WHEN letter = 'm' THEN SET letter = IF(is_lower, 'm', 'M');
      WHEN letter = 'n' THEN SET letter = IF(is_lower, 'n', 'N');
      WHEN letter = 'o' THEN SET letter = IF(is_lower, 'o', 'O');
      WHEN letter = 'p' THEN SET letter = IF(is_lower, 'p', 'P');
      WHEN letter = 'q' THEN SET letter = IF(is_lower, 'q', 'Q');
      WHEN letter = 'r' THEN SET letter = IF(is_lower, 'r', 'R');
      WHEN letter = 's' THEN SET letter = IF(is_lower, 's', 'S');
      WHEN letter = 't' THEN SET letter = IF(is_lower, 't', 'T');
      WHEN letter = 'u' THEN SET letter = IF(is_lower, 'u', 'U');
      WHEN letter = 'v' THEN SET letter = IF(is_lower, 'v', 'V');
      WHEN letter = 'w' THEN SET letter = IF(is_lower, 'w', 'W');
      WHEN letter = 'x' THEN SET letter = IF(is_lower, 'x', 'X');
      WHEN letter = 'y' THEN SET letter = IF(is_lower, 'y', 'Y');
      WHEN letter = 'z' THEN SET letter = IF(is_lower, 'z', 'Z');
      ELSE
        SET letter = letter;
    END CASE;

    -- CONCAT seems to ignore the whitespace character. As a workaround we use
    -- CONCAT_WS with a whitespace separator when the letter is a whitespace.
    SET translit = CONCAT_WS(IF(letter = ' ', ' ', ''), translit, letter);
    SET pos = pos + 1;
  END WHILE;

  RETURN translit;

END $$

DELIMITER ;
~~~


[1]: http://en.wikipedia.org/wiki/Transliteration
[2]: http://en.wikipedia.org/wiki/Diacritic
[3]: http://thedailywtf.com/
[4]: https://github.com/igstan/sql-utils/blob/master/transliterate.sql
