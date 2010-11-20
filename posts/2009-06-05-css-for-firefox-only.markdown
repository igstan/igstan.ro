---------------------------
title: CSS for Firefox only
author: Ionuț G. Stan
date: June 5, 2009
---------------------------

So, how do you write <abbr title="Cascading Style Sheets">CSS</abbr> code that
will be understood only by Firefox?

Same [question][1] was asked by someone on [stackoverflow.com][2]. My first attempt
was to use [XBL][3] and Mozilla's proprietary `-moz-binding` CSS extension in order
to run some JavaScript that will eventually load the intended CSS rules. This
solution was inspired by [Dean Edwards' moz-behaviors library][4] and it looks
like this:

firefox.html

~~~ {.html}
<!DOCTYPE html>

<html>
<head>
<style type="text/css">
body {
  -moz-binding: url(firefox.xml#load-mozilla-css);
}
</style>
</head>
<body>

  <h1>This should be red in Firefox</h1>

</body>
</html>
~~~

firefox.xml

~~~ {.xml}
<?xml version="1.0"?>

<bindings xmlns="http://www.mozilla.org/xbl">
    <binding id="load-mozilla-css">
        <implementation>
            <constructor>
            <![CDATA[
            var link = document.createElement("link");
            link.setAttribute("rel", "stylesheet");
            link.setAttribute("type", "text/css");
            link.setAttribute("href", "ff.css");

            document.getElementsByTagName("head")[0]
                    .appendChild(link);
            ]]>
            </constructor>
        </implementation>
    </binding>
</bindings>
~~~

firefox.css

~~~ {.css}
h1 {
  color: red;
}
~~~

But I felt that there should be a better solution. So I kept digging on
[<abbr title="Mozilla Developer Center">MDC</abbr>][5]. After a couple of clicks
I discovered the easiest solution out there for targeting just the Firefox browser
in our CSS. It uses a Mozilla specific at-rule, called [`@-moz-document`][6], and
it's actually intended for user styling.


Here's the final solution
-------------------------

~~~ {.html}
<!DOCTYPE html>

<html>
<head>
<style type="text/css">
@-moz-document url-prefix() {
  h1 {
    color: red;
  }
}
</style>
</head>
<body>

  <h1>This should be red in FF</h1>

</body>
</html>
~~~


A word of caution
-----------------
We all know how many hours Internet Explorer conditional comments have saved us,
but I believe Firefox is a much, much better browser, so please think twice before
using the above trick. I'm pretty sure there must be some other way. We don't want
to maintain three different stylesheets, for <abbr title="Internet Explorer">IE</abbr>,
<abbr title="Firefox">FF</abbr> and the rest of the browsers out there.


[1]: http://stackoverflow.com/questions/952861/targeting-only-firefox-with-css
[2]: http://stackoverflow.com/
[3]: https://developer.mozilla.org/en/XBL/XBL%5F1.0%5FReference
[4]: http://dean.edwards.name/moz-behaviors/
[5]: https://developer.mozilla.org/en-US/
[6]: https://developer.mozilla.org/en/CSS/@-moz-document
