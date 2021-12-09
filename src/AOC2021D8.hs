
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module AOC2021D8 ( aoc8 ) where

import Data.Maybe (fromJust)
import qualified Data.Map.Strict as M (insert, insertWith, empty, elems, restrictKeys, lookup)
import qualified Data.Set as S (fromList, isSubsetOf)
import qualified Data.List as L (sort, elem, intersect, find, lookup, length)
import qualified Data.Text as T
import Relude

readInt :: Text -> Int -- crash if not an integer
readInt = fromJust . readMaybe . toString . T.filter (/= '+')

aoc8 :: IO (Int, Int)
aoc8 = do
  ss <- readFileText "data/aoc8.dat"
  let outputs = foldl'(\m t -> M.insertWith (+) (T.length t) 1 m) M.empty . concatMap (drop 11 . words) $ lines ss
  let uniqueOutputs = M.restrictKeys  outputs $ S.fromList [2, 3, 4, 7]

  let a = sum $ M.elems uniqueOutputs

  let code :: [Text] -> [(Text, Int)]
      code ts = mm where
        pin = map (toText . L.sort . toString) . sortOn T.length $ ts
        mm = foldl' (\m t -> xxx t m) [] pin
        xxx :: Text -> [(Text, Int)] -> [(Text, Int)]
        xxx t m =
          case T.length t of
                    2 -> (t, 1) : m
                    3 -> (t, 7) : m
                    4 -> (t, 4) : m
                    5 -> let p7 = toString . fst . fromJust . L.find (\p -> snd p == 7) $ m
                             p4 = toString . fst . fromJust . L.find (\p -> snd p == 4) $ m
                          in if (p7 `L.intersect` (toString t)) == p7 then (t, 3) : m
                          else if L.length (p4 `L.intersect` (toString t))  == 2 then (t, 2) : m
                          else (t, 5) : m
                    6 -> let p7 = toString . fst . fromJust . L.find (\p -> snd p == 7) $ m
                             p3 = toString . fst . fromJust . L.find (\p -> snd p == 3) $ m
                          in if not ((p7 `L.intersect` (toString t)) == p7) then (t, 6) : m
                          else if (p3 `L.intersect` (toString t)) == p3 then (t, 9) : m
                          else (t, 0) : m
                    7 -> (t, 8) : m
                    _ -> m
      decode :: [Text] -> [(Text, Int)] -> [Int]
      decode ts pat = map (\t -> fromJust $ L.lookup (toText . L.sort . toString $ t) pat) ts

      calc :: [Int] -> Int
      calc = fst . foldr (\i (s, f) -> (s+i*f, f*10)) (0,1)
      doLine :: [Text] -> Int
      doLine ws = calc . decode (drop 11 ws) . code . take 10 $ ws


  print . map (code . take 10 . words) $ lines ss
  print . map (drop 11 . words) $ lines ss
  print . map (doLine . words) $ lines ss

  let b = sum . map (doLine . words) $ lines ss

  putTextLn $ "result is " <> show a <> " and " <> show b
  pure (a, b)
