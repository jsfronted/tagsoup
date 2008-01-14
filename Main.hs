
module Main(main) where

import System.Environment
import Example.Example
import Example.Regress
import Data.Char(toLower)


helpMsg :: IO ()
helpMsg = putStr $ unlines $
    ["TagSoup, (C) Neil Mitchell 2006-2008"
    ,""
    ,"  tagsoup arguments"
    ,""
    ,"<url> may either be a local file, or a http:// page"
    ,""
    ] ++ map f res
    where
        width = maximum $ map (length . fst) res
        res = map g actions

        g (nam,msg,Left  _) = (nam,msg)
        g (nam,msg,Right _) = (nam ++ " <url>",msg)

        f (lhs,rhs) = "  " ++ lhs ++ replicate (4 + width - length lhs) ' ' ++ rhs
            

actions :: [(String, String, Either (IO ()) (String -> IO ()))]
actions = [("regress","Run the regression tests",Left regress)
          ,("grab","Grab a web page",Right grab)
          ,("parse","Parse a web page",Right parse)
          ,("validate","Validate a page",Right validate)
          ,("hitcount","Get the Haskell.org hit count",Left haskellHitCount)
          ,("spj","Simon Peyton Jones' papers",Left spjPapers)
          ,("ndm","Neil Mitchell's papers",Left ndmPapers)
          ,("time","Current time",Left currentTime)
          ,("google","Google Tech News",Left googleTechNews)
          ,("sequence","Creators on sequence.complete.org",Left rssCreators)
          ,("help","This help message",Left helpMsg)
          ]

main :: IO ()
main = do
    args <- getArgs
    case (args, lookup (map toLower $ head args) $ map (\(a,_,c) -> (a,c)) actions) of
        ([],_) -> helpMsg
        (x:_,Nothing) -> putStrLn ("Error: unknown command " ++ x) >> helpMsg
        ([_],Just (Left a)) -> a
        (x:xs,Just (Left a)) -> do
            putStrLn $ "Warning: expected no arguments to " ++ x ++ " but got: " ++ unwords xs
            a
        ([_,y],Just (Right a)) -> a y
        (x:xs,Just (Right _)) -> do
            putStrLn $ "Error: expected exactly one argument to " ++ x ++ " but got: " ++ unwords xs
            helpMsg
