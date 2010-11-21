---------------------------
title: XHTML no matter what
author: Ionuț G. Stan
date: March 20, 2009
---------------------------


[metropotam.ro][1] changed their layout. Here's what XHTML obsession means (look
after <abbr title="Internet Explorer">IE</abbr> conditional comments).

~~~ {.html}
<base href="http://metropotam.ro/" /><!--[if IE]></base><![endif]-->
~~~

I simply cannot see the reason for such a useless hack. Too bad they forgot to do
the same thing for `script` tags. But I see the reason for the one below (again,
look after <abbr title="Internet Explorer">IE</abbr> conditional comments).

~~~ {.html}
<li class="selected">
  <!--[if lte IE 6]><table><tr><td><![endif]-->
  <ul>
  ...
  </ul>
  <!--[if lte IE 6]></td></tr></table></a><![endif]-->
</li>
~~~

But then again. What's this?

~~~ {.html}
<li><a href="..."><strong>Unde iesim</strong><!--[if gte IE 7]><!--></a><!--<![endif]-->
~~~

Regardless of the above nitpicking though, I like the new layout.


[1]: http://metropotam.ro/
