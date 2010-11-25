-------------------------------
title: Git's environment filter
author: Ionuț G. Stan
date: March 5, 2010
-------------------------------


This is a thing I keep on forgetting although I've done it several times. So, I'm
writing a blog post hoping it will help me memorize this.

So... how do you rewrite Git's history, specifically the environment variables
With `git filter-branch` of course. I frequently need it in order to change the
author and committer email addresses (either from personal to work or the other
way around).

~~~ {.bash}
git filter-branch --env-filter 'export GIT_AUTHOR_EMAIL="email@address.com"' HEAD
git filter-branch --env-filter 'export GIT_COMMITTER_EMAIL="email@address.com"' HEAD
~~~

Don't forget that there are two email addresses, OK? The author's and committer's
one. Oh, and no spaces around the equal sign.

For a more complicated situation see [this answer on serverfault.com][1].


[1]: http://serverfault.com/questions/12373/how-do-i-edit-gits-history-to-correct-an-incorrect-email-address-name
