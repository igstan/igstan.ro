module Main where

import Data.List (sort)
import Control.Monad (forM_, liftM)

import Text.Hakyll (hakyll)
import Text.Hakyll.Render (static, renderChain)
import Text.Hakyll.File (directory, getRecursiveContents)
import Text.Hakyll.CreateContext (createPage, createListing)


main :: IO ()
main = hakyll "http://igstan.ro" $ do
    -- Static directory.
    directory static "css"

    -- Find all post paths.
    postPaths <- liftM (reverse . sort) $ getRecursiveContents "posts"
    let postPages = map createPage postPaths

    -- Render index, including recent posts.
    let index = createListing "index.html" ["templates/postitem.html"]
                              (take 10 postPages) [("title", Left "igstan.ro")]
    renderChain ["index.html", "templates/layout.html"] index

    -- Render all posts list.
    let posts = createListing "posts.html" ["templates/postitem.html"]
                              postPages [("title", Left "All posts")]
    renderChain ["posts.html", "templates/layout.html"] posts

    -- Render all posts.
    forM_ postPages $ renderChain [ "templates/post.html"
                                  , "templates/layout.html"
                                  ]
