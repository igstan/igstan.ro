----------------------------------
title: How not to use dates in PHP
author: Ionuț G. Stan
date: December 20, 2008
----------------------------------


How many times did you find yourself using basic arithmetic operations to make a
range of UNIX timestamps, given that you know the ends of the interval? I'm
talking about something like this:

~~~ {.php}
<?php

date_default_timezone_set('Europe/Bucharest');

$start = strtotime('01 October 2008');
$end   = strtotime('01 November 2008');

$next = $start;
while ($next <= $end) {
    echo date('Y M d', $next) ,'<br>';
    $next += 60*60*24;
}
~~~

If you run the above little script you might be surprised to see that October 26th
appears twice, one after the other.

If you're not aware of Daylight Saving Time you may have hard times understanding
what's happening behind the scenes and solving the problem. In the above snippet
I started the script by specifying that PHP's all date/time functions should use
Bucharest's timezone. That means that my date() call in the for loop would know
that October 26th, 2008 is officially marked as the end of Daylight Saving Time
for Bucharest (as well as whole Europe). In that day 04:00 <abbr title="Ante Meridian">AM</abbr>
became 03:00 <abbr title="Ante Meridian">AM</abbr>, "rewinding" time one hour and
passing from <abbr title="Eastern Europe Summer Time">EEST</abbr> to
<abbr title="Eastern Europe Time">EET</abbr>.

So how can only one hour duplicate a day? Well, by observing <abbr title="Daylight Saving Time">DST</abbr>,
one day in year gets one hour longer, while another day gets one hour shorter.
October 26th, 2008 is the day that got one hour longer, counting a total of 25
hours, while our script is adding 24 hours for each iteration. That's why, when
the counter is supposed to return a UNIX timestamp for October 27th, 2008 it
actually returns the timestamp for October 26, 2008 23:00:00, because now it's
one hour behind <abbr title="Daylight Saving Time">DST</abbr>. Here's a modified
script to show exactly this transition:

~~~ {.php}
<?php

date_default_timezone_set('Europe/Bucharest');

$start = strtotime('01 October 2008');
$end   = strtotime('01 November 2008');

$next = $start;
while ($next <= $end) {
    echo $next ,' ';
    echo date('Y M d H:i:s', $next) ,'<br>';
    $next += 60*60*24;
}

echo '<hr>';
$hours_in_26 = (strtotime('27 October 2008') - strtotime('26 October 2008'));
$hours_in_26 = $hours_in_26 / 60 / 60;
echo "October 26th, has $hours_in_26 hours when observing DST.";
~~~

I've also made a little diagram to highlight the problem. On the left hand side
is the way `date()` function works when we've set a timezone value. On the right
hand side is the way our script works, by treating all days as having only 24
hours. The green rectangle is that one hour difference between our script and
`date()`. The red hours is when <abbr title="Daylight Saving Time">DST</abbr> ends.

<p style="text-align: center;">
    <img src="/files/images/dst.png"
         alt="DST aware versus non DST aware"
         title="DST aware versus non DST aware">
</p>

Now that we know the problem we should fix it and the most simple solution is to
change the timezone. Instead of Europe/Bucharest I could have been used
<abbr title="Greenwich Mean Time">GMT</abbr> and the above script had been worke
 well:

~~~ {.php}
<?php

date_default_timezone_set('GMT');
~~~


Unfortunately, using <abbr title="Greenwich Mean Time">GMT</abbr> is not always
an option, as you want to display users valid dates for their territories, that
is, you want localization (L10N). The other solution, which is better, is to not
rely on arithmetic for such calculations. You're better off using `mktime()`
which, as any other date/time function, is <abbr title="Daylight Saving Time">DST</abbr>
aware.

~~~ {.php}
<?php

date_default_timezone_set('Europe/Bucharest');

$start = strtotime('01 October 2008');
$end   = strtotime('01 November 2008');

$next = $start;
while ($next <= $end) {
    echo date('Y M d H:i:s', $next) ,'<br>';

    list($month, $day, $year) = explode('-', date('n-j-Y', $next));
    $next = mktime(0, 0, 0, $month, $day + 1, $year);
}
~~~

By the way, changing the timezone identifier to "Asia/Jerusalem" would double
October 5th, 2008 in the first version of the script. You may find more about
these on [timeanddate.com][1].


[1]: http://timeanddate.com/
