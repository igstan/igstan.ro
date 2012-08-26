{-# LANGUAGE OverloadedStrings #-}
module Main where

import Prelude hiding (id)
import Control.Arrow ((>>>), (***), arr)
import Control.Category (id)
import Data.Monoid (mempty, mconcat)

import Hakyll

main :: IO ()
main = hakyll $ do
    copyFiles ["favicon.ico", "css/**", "files/**"]

    match "templates/*" $ compile templateCompiler

    match "posts/*" $ do
        route   $ setExtension ".html"
        compile $ pageCompiler
            >>> arr (renderDateField "date" "%B %d, %Y" "Date unknown")
            >>> applyTemplateCompiler "templates/post.html"
            >>> applyTemplateCompiler "templates/layout.html"

    match "posts.html" $ route idRoute
    create "posts.html" $ constA mempty
        >>> arr (setField "title" "All Posts")
        >>> requireAllA "posts/*" generatePostsList
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/layout.html"

    match "index.html" $ route idRoute
    create "index.html" $ constA mempty
        >>> arr (setField "title" "igstan.ro")
        >>> requireAllA "posts/*" (id *** arr (take 10 . reverse) >>> generatePostsList)
        >>> applyTemplateCompiler "templates/index.html"
        >>> applyTemplateCompiler "templates/layout.html"

    match "rss.xml" $ route idRoute
    create "rss.xml" $
        requireAll_ "posts/*"
            >>> arr reverse
            >>> mapCompiler (arr $ copyBodyToField "description")
            >>> renderRss rssFeed

  where
    copyFiles = mapM_ (`match` (route idRoute >> compile copyFileCompiler))


generatePostsList = setFieldA "posts" $
    arr (reverse . chronological)
        >>> require "templates/postitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody


rssFeed :: FeedConfiguration
rssFeed = FeedConfiguration
    { feedRoot        = "http://igstan.ro"
    , feedTitle       = "igstan.ro"
    , feedDescription = "RSS feed for igstan.ro blog"
    , feedAuthorName  = "Ionuț G. Stan"
    }
