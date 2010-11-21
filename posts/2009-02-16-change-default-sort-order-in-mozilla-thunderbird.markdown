-------------------------------------------------------
title: Change default sort order in Mozilla Thunderbird
author: Ionuț G. Stan
date: February 16, 2009
-------------------------------------------------------


I like email and feed messages ordered by date ascending in my Thunderbird, but
its default settings are date descending. So I changed it like this:

 - Go to: Tools -> Options
 - Click "Config Editor..." button
 - Search for "sort"
 - Change value of **mailnews.default_sort_order** from **1** to **2**

In case you had no idea whether Thunderbird has an "about:config" capability
like Firefox, now you know.
