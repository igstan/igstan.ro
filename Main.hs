module Main where

import Control.Arrow ((>>>))
import Control.Monad (forM_, liftM)
import Data.List (sort)

import Text.Hakyll (hakyll)
import Text.Hakyll.Render (static, renderChain)
import Text.Hakyll.Feed (renderRss, FeedConfiguration(..))
import Text.Hakyll.File (directory, getRecursiveContents)
import Text.Hakyll.CreateContext (createPage, createListing)
import Text.Hakyll.ContextManipulations (copyValue)


main :: IO ()
main = hakyll "http://igstan.ro" $ do
    static "favicon.ico"
    directory static "css"
    directory static "files"

    -- Find all post paths.
    postPaths <- liftM (reverse . sort) $ getRecursiveContents "posts"
    let postPages = map createPage postPaths

    -- Render index, including recent posts.
    let index = createListing "index.html" ["templates/postitem.html"]
                              (take 10 postPages) [("title", Left "igstan.ro")]
    renderChain ["index.html", "templates/layout.html"] index

    let feedItems = map (>>> copyValue "body" "description") (take 20 postPages)

    renderRss rssFeed feedItems

    -- Render all posts list.
    let posts = createListing "posts.html" ["templates/postitem.html"]
                              postPages [("title", Left "All Posts")]
    renderChain ["posts.html", "templates/layout.html"] posts

    -- Render all posts.
    forM_ postPages $ renderChain [ "templates/post.html"
                                  , "templates/layout.html"
                                  ]

rssFeed = FeedConfiguration
    { feedUrl         = "rss.xml"
    , feedTitle       = "igstan.ro"
    , feedDescription = "RSS feed for igstan.ro blog"
    , feedAuthorName  = "Ionuț G. Stan"
    }
