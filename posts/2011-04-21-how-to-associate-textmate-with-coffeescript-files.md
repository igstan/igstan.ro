--------------------------------------------------------------------------------
title: How to Associate TextMate With CoffeeScript Files
author: Ionuț G. Stan
date: April 21, 2011
--------------------------------------------------------------------------------


First, tell OS X to use TextMate.app when you try to open `.coffee` files. The
command below will do just that.

~~~ {.bash}
$ defaults write com.apple.LaunchServices LSHandlers -array-add \
"<dict>
    <key>LSHandlerContentTag</key>
    <string>coffee</string>
    <key>LSHandlerContentTagClass</key>
    <string>public.filename-extension</string>
    <key>LSHandlerRoleAll</key>
    <string>com.macromates.textmate</string>
</dict>"
~~~

To associate TextMate's generic document icon with `.coffee` files first go to
`/Applications/TextMate.app/Contents` and open `Info.plist`. At the bottom of
the file there's a section that looks like this:

~~~
{   CFBundleTypeName = "Source";        /* generic source code types */
    CFBundleTypeExtensions = (
        coffee, g, vss, d, e, gri, inf, mel, build, re,
        textmate, fxscript, lgt
    );
    CFBundleTypeIconFile = TMDocument;
    CFBundleTypeRole = Editor;
}
~~~

Put `coffee` inside the CFBundleTypeExtensions listing (as you can see above).
Now rebuild the LaunchServices database:

~~~ {.bash}
$ ln -s /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister lsregister
$ lsregister -kill -r -domain local -domain system -domain user
~~~

That should be all.
