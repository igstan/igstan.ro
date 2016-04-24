--------------------------------------------------------------------------------
title: How to Lay out a Modular Java/GWT Project
author: Ionuț G. Stan
date: July 18, 2011
--------------------------------------------------------------------------------


First of all, do yourself a favor and don't mix server-side and client-side code
into the same project. You could, but I doubt all of your colleagues/developers
will know how to correctly handle the separation of responsibilities. Having the
code base separated into two or three projects will help you obtain more modular
code.

Another, actually more compelling, reason to have a separate project for your
client-side code is to obtain more responsiveness from your IDE. I only have
experience with Eclipse, but it takes a lot less to scan (for various validations,
like validation that your `*.ui.xml` file declares all the fields specified in the
corresponding UiBinder class) just the client-side code when you perform a file
save. Having the [GWT][1] plugin scan Hibernate files makes no sense.

[1]: http://code.google.com/webtoolkit/
