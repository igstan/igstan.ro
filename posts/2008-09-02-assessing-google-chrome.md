------------------------------
title: Assessing Google Chrome
author: Ionuț G. Stan
date: September 02, 2008
------------------------------


I have already discovered some bugs and managed to crash two tabs in under 3
minutes when I interrupted for writing this post. There are also some features
I miss from Firefox. Details...


Bugs
----

   1. It erroneously fills some form fields from a forum I often visit overriding
      the input's value attribute (at least that's what I was able to see with the
      built in, à la firebug, inspector, which is good news by the way.)
   2. The whole browser freezed when opening a link from the above mentioned forum
      that pointed to my weblog home page. I succeded to take back control when
      killing one process from the Windows task manager, which aparently made two
      tabs, not one (I killed one process, not tow), to show the sad face of failure.
   3. Opening a 155 page <abbr title="Portable Document Format">PDF</abbr> document
      made iresponsive the whole browser, not just the respective tab as said in
      the comic book and reduced 4 tab-processes to only one process in the
      Windows task manager which took the whole browser down when killing it.
   4. After reboot the <abbr title="Portable Document Format">PDF</abbr> page
      still isn't rendered as it should and any interaction with it slows down
      (to freezing) the whole browser. (At least this blog entry was preserved
      in the textarea).
   5. There appear to be some bugs with the character encoding support. In
      Romanian we have special characters like "ăîâșț" that aren't rendered as
      they should nor when the enconding is ISO-8859-2 (which I know should be
      OK for Romanian), nor when I change it to UTF-8. Anyways, the website isn't
      sending a charset in the <abbr title="HyperText Transfer Protocol">HTTP</abbr>
      headers (according to LiveHTTPHeaders), on other web sites it is OK.


Missing features
----------------

   1. Can't scroll pages while middle-clicking :-( That's awful for me, a reason not to use a browser.
   2. Iframes used for rich text editing don't have spell checking, whereas textarea elements do.
   3. I can't turn off spell checking on textarea elements.
   4. Maybe not a missing features but I couldn't find it. Where can I choose
      another engine from my opensearch engines that were imported from Firefox
      after the installation? (later on) it may be redundant as all the opensearch
      providers are available for querying inside the address bar.
   5. I'd really like to disable the close buttons on every opened tab.
   6. When opening many tabs (> 20) there's no way to know what site is in which
      tab, except for the favicon (if there is one) that is being displayed. That
      is because a tab's width is in inverse ratio with the number of tabs. I
      tend to like more the scrolling feature of Firefox in such a case (but
      maybe I'm just spoiled by Firefox). Anyway, they load fine dispite the
      large number.
   7. It comes with built-in support for Adobe Flash and Adobe PDF but not Quick Time.
   8. At this moment I have 7 folders of bookmarks imported from Firefox. When
      clicking one, there's a submenu that popups and the bookmars contained can
      be seen, well, now I expect that hovering another folder will open it
      automatically without click on it again but it doesn't happen like this,
      you have to click it again. I think on a Windows <abbr title="Operating System">OS</abbr>
      this is common practice for user interface (not to be forced to click again).
   9. I don't have a history list by the back/forward buttons.
  10. An RSS/Atom reader like in Firefox.
  11. No "Zoom page" tool, only zoom text with <kbd>CTRL</kbd>+<kbd>+</kbd>,
      <kbd>CTRL</kbd>+<kbd>-</kbd> and <kbd>CTRL</kbd>+<kbd>0</kbd> just like in Firefox.
  12. I can't middle click the back/forward button to open a previous page in new tab.


Good things/features
--------------------

   1. The HTML inspector (mentioned above) and <abbr title="JavaScript">JS</abbr>
      debugger and console.
   2. Searching through the installation files I discovered some js scripts that
      deal with the local data store and seemed to be integrated with the Inspector
      but I couldn't lauch it from the browser.
   3. The source turn links into real links so that I can quickly go to the 
      <abbr title="Cascading Style Sheets">CSS</abbr> and <abbr title="JavaScript">JS</abbr>
      files of a website.
   4. Mozilla Prism's idea of web pages that could be saved as desktop apps is
      now to be found in Google Chrome. You can save a shortcut to Gmail, for
      example, on the desktop, quick launch bar and start menu. Details
   5. It has "View Frame Source" when right clicking on an iframe element.
   6. I like the search capabilities in the address bar (I always wished it in Firefox).
   7. The "bookmark this page" from the address bar is like Firefox's, except it misses tagging.
   8. Incognito mode.
   9. Speed of loading for some of the pages I visited.
  10. Incremental search + it shows how many results it has found until that
      point + highlighting of matching keywords + <kbd>F3</kbd> does work to jump to next
      result + ... the place of the search box :).
  11. <kbd>CTRL</kbd>+<kbd>J</kbd> opens downloads tab (just like in Firefox).
  12. Detaching tabs in standalone windows.
  13. X/Y resizable textarea element, but the resizer image has a non-transparent
      upper-left corner.


WTFs
----

   1. The installation place. On my system (Windows XP Professional 32bit) it was in
      `C:\Documents and Settings\username\Local Settings\Application Data\Google\Chrome\Application\chrome.exe`,
      along with Gears and... GoogleUpdate.
