{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}
module Lib where

import System.Random

import Control.Arrow (second)
import Control.Monad (replicateM, guard)

import Data.Function (on)
import Data.Ord (comparing)
import Data.Maybe
import qualified Data.List as List
import Data.Map (Map, (!))
import qualified Data.Map as Map

import Debug.Trace

sniff input = trace (show input) input

-- | Problem 1: Find the last element of a list.
myLast :: [a] -> a
myLast [] = error "empty list"
myLast (x:[]) = x
myLast (_:xs) = myLast xs

-- | Problem 2: Find the last but one element of a list.
myButLast :: [a] -> a
myButLast [] = error "empty list"
myButLast (_:[]) = error "list with one element"
myButLast (x:_:[])  = x
myButLast (_:xs) = myButLast xs

-- | Problem 3: Find the K'th element of a list. The first element in the list is number 1.
elementAt :: Integral d => [a] -> d -> a
elementAt [] _ = error "empty list"
elementAt (x:_) 1 = x
elementAt (_:xs) index = elementAt xs (index - 1)

-- | Problem 4: Find the number of elements of a list.
myLength :: Integral d => [a] -> d
myLength [] = 0
myLength (_:xs) = 1 + myLength xs

-- | Problem 5: Reverse a list.
myReverse :: [a] -> [a]
myReverse [] = []
myReverse (x:xs) = myReverse xs ++ [x]

-- | Problem 6: Find out whether a list is a palindrome. A palindrome can be read forward or backward; e.g. (x a m a x).
isPalindrome :: Eq a => [a] -> Bool
isPalindrome xs = xs == reverse xs

-- | Problem 7: Flatten a nested list structure.
-- Transform a list, possibly holding lists as elements into a `flat' list by replacing each list with its elements (recursively).
data NestedList a = Elem a | List [NestedList a]
flatten :: NestedList a -> [a]
flatten (Elem x) = [x]
flatten (List xs) = concat $ map flatten xs


-- | Problem 8: Eliminate consecutive duplicates of list elements.
compress :: Eq a => [a] -> [a]
compress [] = []
compress [x] = [x]
compress (x:x':xs)
  | x == x' = compress $ x:xs
  | otherwise = x:(compress $ x':xs)
-- compress = map head . group

-- | Problem 9: Pack consecutive duplicates of list elements into sublists. If a list contains repeated elements they should be placed in separate sublists.
pack :: Eq a => [a] -> [[a]]
pack [] = []
pack [x] = [[x]]
pack (x:x':xs)
  | x == head group = ([x] ++ group):groups
  | otherwise = [x]:group:groups
  where
    group:groups = pack (x':xs)

-- | Problem 10: Run-length encoding of a list. Use the result of problem P09 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as lists (N E) where N is the number of duplicates of the element E.
encode :: Eq a => [a] -> [(Int, a)]
encode xs = map (\group -> (length group, head group)) $ pack xs

-- | Problem 11: Modified run-length encoding.
-- Modify the result of problem 10 in such a way that if an element has no duplicates it is simply copied into the result list. Only elements with duplicates are transferred as (N E) lists.
data ModifiedEncoding a
  = Single a
  | Multiple Int a
  deriving (Show, Eq)

modifiedEncoding :: (Int, a) -> ModifiedEncoding a
modifiedEncoding (1, x) = Single x
modifiedEncoding (n, x) = Multiple n x

encodeModified :: Eq a => [a] -> [ModifiedEncoding a]
encodeModified xs = map modifiedEncoding $ encode xs

-- | Problem 12: Decode a run-length encoded list.
-- Given a run-length code list generated as specified in problem 11. Construct its uncompressed version.
decodeModified :: [ModifiedEncoding a] -> [a]
decodeModified encoded = concat $ map decode encoded
  where
    decode (Single x) = [x]
    decode (Multiple n x) = replicate n x

-- | Problem 13: Run-length encoding of a list (direct solution).
-- Implement the so-called run-length encoding data compression method directly. I.e. don't explicitly create the sublists containing the duplicates, as in problem 9, but only count them. As in problem P11, simplify the result list by replacing the singleton lists (1 X) by X.
encodeDirect :: Eq a => [a] -> [ModifiedEncoding a]
encodeDirect = map modifiedEncoding . encode'
  where
    encode' = foldr f []
    f x [] = [(1, x)]
    f x ((n, y):ys)
      | x == y = (n + 1, x):ys
      | otherwise = (1, x):(n, y):ys

-- | Problem 14: Duplicate the elements of a list.
dupli :: [a] -> [a]
dupli [] = []
dupli (x:xs) = x:x:dupli xs

-- | Problem 15: Replicate the elements of a list a given number of times.
repli :: [a] -> Int -> [a]
repli [] _ = []
repli (x:xs) n = (take n $ repeat x) ++ (repli xs n)

-- | Problem 16: Drop every N'th element from a lis.
dropEvery :: Integral d => [a] -> d -> [a]
dropEvery xs n = unenumerate $ filter (\(i, _) -> i `mod` n /= (n - 1)) $ enumerate xs
  where
    enumerate = zip [0..]
    unenumerate = map snd

-- | Problem 17: Split a list into two parts; the length of the first part is given.

-- Do not use any predefined predicates.
split :: [a] -> Int -> ([a], [a])
split xs n = helper ([], xs) n
  where
    helper (xs, ys) 0 = (xs, ys)
    helper (xs, []) _ = (xs, [])
    helper (xs, y:ys) n = helper (xs ++ [y], ys) (n - 1)

-- | Problem 18: Extract a slice from a list.
-- Given two indices, i and k, the slice is the list containing the elements between the i'th and k'th element of the original list (both limits included). Start counting the elements with 1.
slice :: [a] -> Int -> Int -> [a]
slice xs lo hi = drop (lo - 1) $ take hi xs

-- | Problem 19: Rotate a list N places to the left.
-- Hint: Use the predefined functions length and (++).
rotate :: [a] -> Int -> [a]
rotate xs n = drop n' xs ++ take n' xs
  where
    n' = (length xs + n) `mod` (length xs)

-- | Problem 20: Remove the K'th element from a list.
removeAt :: Int -> [a] -> (a, [a])
removeAt k xs = (xs !! (k - 1), take (k - 1) xs ++ drop k xs)

-- | Problem 21: Insert an element at a given position into a list.
insertAt :: a -> [a] -> Int -> [a]
insertAt x xs index = take (index - 1) xs ++ [x] ++ drop (index - 1) xs

-- | Problem 22: Create a list containing all integers within a given range.
range :: Enum a => a -> a -> [a]
range lo hi = [lo..hi]

-- | Problem 23: Extract a given number of randomly selected elements from a list.
rnd_select :: [a] -> Int -> IO [a]
rnd_select xs n
  | n < 0 = error "n has to be > 0"
  | otherwise = do
      generator <- getStdGen
      return $ take n [xs !! index | index <- randomRs (0, length xs - 1)  generator]

-- | Problem 24: Lotto: Draw N different random numbers from the set 1..M.
diff_select :: Int -> Int -> IO [Int]
diff_select n m = rnd_select [1..m] n

-- | Problem 25: Generate a random permutation of the elements of a list.
rnd_permu :: [a] -> IO [a]
rnd_permu xs = rnd_select xs (length xs)

-- | Problem 26: Generate the combinations of K distinct objects chosen from the N elements of a list
-- In how many ways can a committee of 3 be chosen from a group of 12 people? We all know that there are C(12,3) = 220 possibilities (C(N,K) denotes the well-known binomial coefficients). For pure mathematicians, this result may be great. But we want to really generate all the possibilities in a list.
combinations :: Int -> [a] -> [[a]]
combinations k xs = backtrack xs [] (length xs) k 0
  where
    backtrack :: [a] -> [a] -> Int -> Int -> Int -> [[a]]
    backtrack xs current n k start
      | length current == k = [current]
      | otherwise = concat $ [backtrack xs (current ++ [xs !! i]) n k (i + 1) | i <- [start..(n - 1)]]

-- | Problem 27: Group the elements of a set into disjoint subsets.
group :: [Int] -> [a] -> [[[a]]]
group [] _ = [[]]
group (n:ns) xs = [g:gs | (g, rs) <- combination n xs, gs <- group ns rs]
  where
    combination 0 xs = [([], xs)]
    combination _ [] = []
    combination n (x:xs) = [(x:ys, zs) | (ys, zs) <- combination (n - 1) xs] ++ [(ys, x:zs) | (ys, zs) <- combination n xs]

-- | Problem 28 (a): Sorting a list of lists according to length of sublists
lsort :: [[a]] -> [[a]]
lsort = List.sortOn length

-- | Problem 28 (b): Sorting a list of lists according to length of frequency sublists
lfsort :: [[a]] -> [[a]]
lfsort xs = List.sortOn (\x -> frequencies ! (length x)) xs
  where
    frequencies :: Map Int Int
    frequencies = foldr (\x -> Map.insertWith (+) (length x) 1) Map.empty xs

-- | Problem 31: Determine whether a given integer number is prime.
isPrime :: Integral d => d -> Bool
isPrime n = List.find (>= n) primes == Just n

primes :: Integral d => [d]
primes = sieve_of_eratosthenes [2..]

sieve_of_eratosthenes :: Integral d => [d] -> [d]
sieve_of_eratosthenes [] = undefined
sieve_of_eratosthenes (x:xs) = x:sieve_of_eratosthenes [i | i <- xs, i `mod` x > 0]

-- | Problem 32: Determine the greatest common divisor of two positive integer numbers. Use Euclid's algorithm.
myGCD :: Integral d => d -> d -> d
myGCD a b
  | b == 0 = abs a
  | otherwise = myGCD b (a `mod` b)

-- | Problem 33: Determine whether two positive integer numbers are coprime. Two numbers are coprime if their greatest common divisor equals 1.
coprime :: Integral d => d -> d -> Bool
coprime a b = gcd a b == 1

-- | Problem 34: Calculate Euler's totient function phi(m).
-- Euler's so-called totient function phi(m) is defined as the number of positive integers r (1 <= r < m) that are coprime to m.
totient :: Integral d => d -> d
totient m = List.genericLength $ [r | r <- [1..(m - 1)], coprime r m]

-- | Problem 35: Determine the prime factors of a given positive integer. Construct a flat list containing the prime factors in ascending order.
primeFactors :: Integral d => d -> [d]
primeFactors n = concat [List.genericReplicate (multiplicity n p) p | p <- takeWhile (<= n) primes, n `mod` p == 0]

sqrt' :: Integral d => d -> d
sqrt' n = floor $ sqrt $ fromIntegral n

multiplicity :: Integral d => d -> d -> d
multiplicity dividend divisor = case dividend `divMod` divisor of
  (quotient, 0) -> 1 + multiplicity quotient divisor
  _ -> 0

-- | Problem 36: Determine the prime factors of a given positive integer.
prime_factors_mult :: Integral d => d -> [(d, d)]
prime_factors_mult n = [(p, multiplicity n p) | p <- takeWhile (<= n) primes, n `mod` p == 0]

-- | Problem 37: Calculate Euler's totient function phi(m) (improved)
-- See problem 34 for the definition of Euler's totient function. If the list of the prime factors of a number m is known in the form of problem 36 then the function phi(m) can be efficiently calculated as follows: Let ((p1 m1) (p2 m2) (p3 m3) ...) be the list of prime factors (and their multiplicities) of a given number m. Then phi(m) can be calculated with the following formula:
-- 
-- phi(m) = (p1 - 1) * p1 ** (m1 - 1) * 
--          (p2 - 1) * p2 ** (m2 - 1) * 
--          (p3 - 1) * p3 ** (m3 - 1) * ...
-- Note that a ** b stands for the b'th power of a.
totient' :: Integral d => d -> d
totient' m = product $ [(p - 1) * p ^ (k - 1) | (p, k) <- prime_factors_mult m]

-- | Problem 38: Compare the two methods of calculating Euler's totient function.
-- Use the solutions of problems 34 and 37 to compare the algorithms. Take the number of reductions as a measure for efficiency. Try to calculate phi(10090) as an example.
-- (no solution required)
-- NOTE: gcd(a, b) has a time complexity of O(log(min(a, b)))
-- So coprime is also of O(log(min(a, b)))
-- totient from (34) is then of O(m^2 * log(m))
-- totient' from (37) is of O(m^2)

-- | Problem 39: A list of prime numbers.
-- Given a range of integers by its lower and upper limit, construct a list of all prime numbers in that range.
primesR :: Integral d => d -> d -> [d]
primesR lo hi = takeWhile (<= hi) $ dropWhile (<= lo) $ primes

-- | Problem 40: Goldbach's conjecture.
-- Goldbach's conjecture says that every positive even number greater than 2 is the sum of two prime numbers. Example: 28 = 5 + 23. It is one of the most famous facts in number theory that has not been proved to be correct in the general case. It has been numerically confirmed up to very large numbers (much larger than we can go with our Prolog system). Write a predicate to find the two prime numbers that sum up to a given even integer.
goldbach :: Integral d => d -> (d, d)
goldbach n | n <= 2 || odd n = undefined
goldbach n = head [(x, y) | x <- possibilities, y <- filter (>= x) possibilities, x + y == n]
  where
    possibilities = takeWhile (<= n) primes

-- | Problem 41: Given a range of integers by its lower and upper limit, print a list of all even numbers and their Goldbach composition.
-- In most cases, if an even number is written as the sum of two prime numbers, one of them is very small. Very rarely, the primes are both bigger than say 50. Try to find out how many such cases there are in the range 2..3000.
goldbachList :: Integral d => d -> d -> [(d, d)]
goldbachList lo hi = map goldbach $ takeWhile (<= hi) $ dropWhile (<= lo) evens
  where
    evens :: Integral d => [d]
    evens = [2, 4..]

goldbachList' :: Integral d => d -> d -> d -> [(d, d)]
goldbachList' lo hi limit = [(a, b) | (a, b) <- goldbachList lo hi, a > limit && b > limit]

-- | Problem 46: Define predicates and/2, or/2, nand/2, nor/2, xor/2, impl/2 and equ/2 (for logical equivalence) which succeed or fail according to the result of their respective operations; e.g. and(A,B) will succeed, if and only if both A and B succeed.
-- A logical expression in two variables can then be written as in the following example: and(or(A,B),nand(A,B)).
-- Now, write a predicate table/3 which prints the truth table of a given logical expression in two variables.
type Predicate = Bool -> Bool -> Bool

infixr 3 `and'`
and' :: Predicate
True `and'` True = True
_ `and'` _ = False

infixr 2 `or'`
or' :: Predicate
False `or'` False = False
_ `or'` _ = True

not' :: Bool -> Bool
not' True = False
not' False = True

infixr 3 `nand'`
nand' :: Predicate
a `nand'` b = not' $ a `and'` b

infixr 2 `nor'`
nor' :: Predicate
a `nor'` b = not' $ a `or'` b

infixr 1 `xor'`
xor' :: Predicate
True `xor'` False = True
False `xor'` True = True
_ `xor'` _ = False

-- | a implies b
impl' :: Predicate
a `impl'` b = (not' a) `or'` b

infixr 0 `equ'`
equ' :: Predicate
True `equ'` True = True
False `equ'` False = True
_ `equ'` _ = False

-- | Truth Table
table :: (Predicate) -> String
table predicate = unlines [List.intercalate "\t" $ map show $ [a, b, predicate a b] | a <- [False, True], b <- [False, True]]

-- | Problem 47: Truth tables for logical expressions (2).
-- Continue problem P46 by defining and/2, or/2, etc as being operators. This allows to write the logical expression in the more natural way, as in the example: A and (A or not B). Define operator precedence as usual; i.e. as in Java.
-- (Done with Problem 46)

-- | Problem 48: Truth tables for logical expressions (3).
-- Generalize problem P47 in such a way that the logical expression may contain any number of logical variables. Define table/2 in a way that table(List,Expr) prints the truth table for the expression Expr, which contains the logical variables enumerated in List.
tablen :: Integral d => d -> ([Bool] -> Bool) -> String
tablen n predicate = unlines $ [List.intercalate "\t" $ map show $ input ++ [predicate input] | input <- replicateM (fromIntegral n) [False, True]]

-- | Problem 49: Gray Code
gray :: Integral d => d -> [String]
gray n | n < 1 = undefined
gray 1 = ["0", "1"]
gray n = ['0':code | code <- previous] ++ ['1':code | code <- reverse previous]
  where
    previous = gray (n - 1)

-- | Problem 50: Huffman codes.
-- We suppose a set of symbols with their frequencies, given as a list of fr(S,F) terms. Example: [fr(a,45),fr(b,13),fr(c,12),fr(d,16),fr(e,9),fr(f,5)]. Our objective is to construct a list hc(S,C) terms, where C is the Huffman code word for the symbol S. In our example, the result could be Hs = [hc(a,'0'), hc(b,'101'), hc(c,'100'), hc(d,'111'), hc(e,'1101'), hc(f,'1100')] [hc(a,'01'),...etc.].
huffman :: Integral d => [(Char, d)] -> [(Char, String)]
huffman = shrink . map (\(c, p) -> (p, [(c ,"")])) . List.sortOn snd
  where
    shrink [(_, xs)] = List.sortOn fst xs
    shrink (x:x':xs) = shrink $ insertOn fst (add x x') xs
    add (p, xs) (p', xs') = (p + p', prefixing '0' xs ++ prefixing '1' xs')
    prefixing c = map (second (c:))
    insertOn f = List.insertBy (comparing f)

-- | Binary Tree
data Tree a
  = Empty
  | Branch a (Tree a) (Tree a)
  deriving (Show, Eq)

leaf :: a -> Tree a
leaf x = Branch x Empty Empty

-- | Problem 54A: Non-solution: Check whether a given term represents a binary tree
-- Haskell's type system ensures that all terms of type Tree a are binary trees: it is just not possible to construct an invalid tree with this type. Hence, it is redundant to introduce a predicate to check this property: it would always return True.

-- | Problem 55: Construct completely balanced binary trees
-- In a completely balanced binary tree, the following property holds for every node: The number of nodes in its left subtree and the number of nodes in its right subtree are almost equal, which means their difference is not greater than one.
--
-- Write a function cbal-tree to construct completely balanced binary trees for a given number of nodes. The predicate should generate all solutions via backtracking. Put the letter 'x' as information into all nodes of the tree.
cbalTree :: Integral d => d -> [Tree Char]
cbalTree 0 = [Empty]
cbalTree n = [Branch 'x' left right | i <- [q..q + r],
                                      left <- cbalTree i,
                                      right <- cbalTree (n - i - 1)]
  where
    (q, r) = (n - 1) `quotRem` 2

-- | Problem 56: Symmetric binary trees
-- Let us call a binary tree symmetric if you can draw a vertical line through the root node and then the right subtree is the mirror image of the left subtree. Write a predicate symmetric/1 to check whether a given binary tree is symmetric. Hint: Write a predicate mirror/2 first to check whether one tree is the mirror image of another. We are only interested in the structure, not in the contents of the nodes.
mirror :: Tree a -> Tree a -> Bool
mirror Empty Empty = True
mirror (Branch _ lleft lright) (Branch _ rleft rright) = mirror lleft rright && mirror lright rleft
mirror _ _ = False

symmetric :: Tree a -> Bool
symmetric Empty = True
symmetric tree = mirror tree tree

-- | Problem 57: Binary search trees (dictionaries)
-- Use the predicate add/3, developed in chapter 4 of the course, to write a predicate to construct a binary search tree from a list of integer numbers.
construct :: Ord a => [a] -> Tree a
construct = foldl (flip add) Empty
  where
    add :: Ord a => a -> Tree a -> Tree a
    add value Empty = Branch value Empty Empty
    add value tree@(Branch root left right) = case compare value root of
      LT -> Branch root (add value left) right
      GT -> Branch root left (add value right)
      EQ -> tree

-- | Problem 58: Generate-and-test paradigm
symCbalTrees :: Integral d => d -> [Tree Char]
symCbalTrees = filter symmetric . cbalTree

-- | Problem 59: Construct height-balanced binary trees
-- In a height-balanced binary tree, the following property holds for every node: The height of its left subtree and the height of its right subtree are almost equal, which means their difference is not greater than one.
-- Construct a list of all height-balanced binary trees with the given element and the given maximum height.
hbalTree :: Integral d => a -> d -> [Tree a]
hbalTree value h = trees `List.genericIndex` h
  where
    trees = [Empty]:[Branch value Empty Empty]:(zipWith combine (tail trees) trees)
    combine trees shorters = [Branch value left right | (lefts, rights) <- [(shorters, trees), (trees, trees), (trees, shorters)], left <- lefts, right <- rights]

-- | Problem 60: Construct height-balanced binary trees with a given number of nodes
-- Consider a height-balanced binary tree of height H. What is the maximum number of nodes it can contain?
-- Clearly, MaxN = 2H - 1. However, what is the minimum number MinN? This question is more difficult. Try to find a recursive statement and turn it into a function minNodes that returns the minimum number of nodes in a height-balanced binary tree of height H.
-- On the other hand, we might ask: what is the maximum height H a height-balanced binary tree with N nodes can have? Write a function maxHeight that computes this.
-- Now, we can attack the main problem: construct all the height-balanced binary trees with a given number of nodes. Find out how many height-balanced trees exist for N = 15.
hbalTreeNodes :: a -> Int -> [Tree a]
hbalTreeNodes _ 0 = [Empty]
hbalTreeNodes value n = concatMap filter' [min_height..max_height]
  where
    filter' = filter ((== n) . nodes) . hbalTree value
    min_nodes = 0:1:zipWith ((+) . (+1)) min_nodes (tail min_nodes)

    min_height = ceiling $ logBase 2 $ fromIntegral $ n + 1
    max_height = (fromJust $ List.findIndex (> n) min_nodes) - 1

    nodes Empty = 0
    nodes (Branch _ left right) = nodes left + nodes right + 1

-- | Problem 61: Count the leaves of a binary tree
-- A leaf is a node with no successors. Write a predicate count_leaves/2 to count them.
countLeaves :: Integral d => Tree a -> d
countLeaves Empty = 0
countLeaves (Branch _ Empty Empty) = 1
countLeaves (Branch _ left right) = countLeaves left + countLeaves right

-- | Problem 61a: Collect the leaves of a binary tree in a list
-- A leaf is a node with no successors. Write a predicate leaves/2 to collect them in a list.
leaves :: Tree a -> [a]
leaves Empty = []
leaves (Branch value Empty Empty) = [value]
leaves (Branch _ left right) = leaves left ++ leaves right

-- | Problem 62: Collect the internal nodes of a binary tree in a list
-- An internal node of a binary tree has either one or two non-empty successors. Write a predicate internals/2 to collect them in a list.
internals :: Tree a -> [a]
internals Empty = []
internals (Branch _ Empty Empty) = []
internals (Branch value left right) = value:internals left ++ internals right

-- | Problem 62b: Collect the nodes at a given level in a list
-- A node of a binary tree is at level N if the path from the root to the node has length N-1. The root node is at level 1. Write a predicate atlevel/3 to collect all nodes at a given level in a list.
atLevel :: Integral d => Tree a -> d -> [a]
atLevel Empty _ = []
atLevel (Branch value left right) level
  | level == 1 = [value]
  | otherwise = atLevel left (level - 1) ++ atLevel right (level - 1)

-- | Problem 63: Construct a complete binary tree
-- A complete binary tree with height H is defined as follows:
-- The levels 1,2,3,...,H-1 contain the maximum number of nodes (i.e 2**(i-1) at the level i)
-- In level H, which may contain less than the maximum possible number of nodes, all the nodes are "left-adjusted". This means that in a levelorder tree traversal all internal nodes come first, the leaves come second, and empty successors (the nil's which are not really nodes!) come last.
-- Particularly, complete binary trees are used as data structures (or addressing schemes) for heaps.
-- We can assign an address number to each node in a complete binary tree by enumerating the nodes in level-order, starting at the root with number 1. For every node X with address A the following property holds: The address of X's left and right successors are 2*A and 2*A+1, respectively, if they exist. This fact can be used to elegantly construct a complete binary tree structure.
-- Write a predicate complete_binary_tree/2.
completeBinaryTree :: Integral d => d -> Tree Char
completeBinaryTree 0 = Empty
completeBinaryTree nodes = Branch 'x' (completeBinaryTree left) (completeBinaryTree right)
  where
    nodes' = nodes - 1
    left = nodes' - right
    right = nodes' `div` 2

isCompleteBinaryTree :: Tree a -> Bool
isCompleteBinaryTree = isJust . complete_height
  where
    complete_height Empty = Just 0
    complete_height (Branch _ left right) = do
      left_height <- complete_height left
      right_height <- complete_height right
      guard $ abs (left_height - right_height) <= 1
      return $ left_height + 1

-- | Problem 64: Given a binary tree as the usual Prolog term t(X,L,R) (or nil). As a preparation for drawing the tree, a layout algorithm is required to determine the position of each node in a rectangular grid. Several layout methods are conceivable, one of them is shown in the illustration below:
-- In this layout strategy, the position of a node v is obtained by the following two rules:
-- x(v) is equal to the position of the node v in the inorder sequence
-- y(v) is equal to the depth of the node v in the tree
-- Write a function to annotate each node of the tree with a position, where (1,1) in the top left corner or the rectangle bounding the drawn tree.
type Coordinate d = (d, d)
layout :: Integral d => Tree a -> Tree (a, Coordinate d)
layout = fst . layout' (1, 1)
  where
    layout' (i, _) Empty = (Empty, i)
    layout' (i, j) (Branch value left right) = (Branch (value, (i', j)) left' right', i'')
      where
        (left', i') = layout' (i, j + 1) left
        (right', i'') = layout' (i' + 1, j + 1) right

-- | Problem 65: An alternative layout method is depicted in the illustration below:
-- Find out the rules and write the corresponding function. Hint: On a given level, the horizontal distance between neighboring nodes is constant.
-- Use the same conventions as in problem P64 and test your function in an appropriate way.
layout' :: Integral d => Tree a -> Tree (a, Coordinate d)
layout' tree = layout'' (2 ^ (depth' - 1) - 2 ^ (depth' - left_depth') + 1, 1) (2 ^ (depth' - 2)) tree
  where
    depth :: Integral d => Tree a -> d
    depth Empty = 0
    depth (Branch _ left right) = (max `on` depth) left right + 1
    depth' = depth tree

    left_depth :: Integral d => Tree a -> d
    left_depth Empty = 0
    left_depth (Branch _ left _) = left_depth left + 1
    left_depth' = left_depth tree

    layout'' (i, j) sep Empty = Empty
    layout'' (i, j) sep (Branch value left right) = Branch (value, (i, j))
                                                           (layout'' (i - sep, j + 1) (sep `div` 2) left)
                                                           (layout'' (i + sep, j + 1) (sep `div` 2) right)


