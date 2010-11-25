-------------------------------------------------
title: How to install Python libraries on Windows
author: Ionuț G. Stan
date: September 04, 2008
-------------------------------------------------


Whenever you have to install another Python library on a Windows <abbr title="Operating System">OS</abbr>
is good to do it like this from the command line:

    cd path/to/library/dir
    python setup.py bdist --format=wininst

This will pack all the source into an installer that can be found under
"path/to/library/dir/dist".

Using this method you will later be able to go to "Control Panel" -> "Add or
Remove Programs" and uninstall such a library from there.

For other platforms and options see [Python documentation on creating built
distributions][1].


[1]: http://docs.python.org/dist/built-dist.html
