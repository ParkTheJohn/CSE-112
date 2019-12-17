import Data.Char
import System.IO
import System.Environment 

-- maps labels line numbers and variables to values - uses float for line numbers for simplicity
type SymTable = [(String,Float)]

data Expr = 
    Constant Float | 
    Var String | 
    Plus Expr Expr |
    Minus Expr Expr |
    Times Expr Expr |
    Div Expr Expr |
    LT_ Expr Expr |
    GT_ Expr Expr |
    LE_ Expr Expr |
    GE_ Expr Expr |
    EQ_ Expr Expr |
    NEQ_ Expr Expr |
    ExprError String |
    Str String deriving (Show) 

data Stmt =
    Let String Expr |
    Print [Expr] | 
    If Expr String |
    Input String |
    Error String deriving (Show)

-- check for labels for the first expression of the line by checking whether it has a colon at the end.
isLabel :: String -> Bool
isLabel label = if (last label) == ':' then True else False 

-- takes a list of tokens as strings and returns the parsed expression
parseExpr :: [String] -> Expr
parseExpr (e1:"+":e2:[]) = Plus (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"-":e2:[]) = Minus (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"*":e2:[]) = Times (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"/":e2:[]) = Div (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"<":e2:[]) = LT_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:">":e2:[]) = GT_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"<=":e2:[]) = LE_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:">=":e2:[]) = GE_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"==":e2:[]) = EQ_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:"!=":e2:[]) = NEQ_ (parseExpr [e1]) (parseExpr [e2])
parseExpr (e1:x:e2:[]) = ExprError (unwords (e1:x:e2:[]))
parseExpr (x:rest) = if (isAlpha (head x) && rest == []) then (Var x) 
                        else if ( head x == '"') && (last x == '"') then (Str (init (tail x))) 
                            else if ( head x == '"') && ((last (last rest)) == '"') then let longString = unwords (x:rest) in (Str (init (tail longString)))
                                else if ( head x == '"') then let longString = unwords (x:rest) in (Str (init (tail longString)))
                                    else if (isDigit (head x) && rest == []) then (Constant (read x))
                                        else (ExprError (unwords (x:rest)))

-- takes the first token which should be a keyword and a list of the remaining tokens and returns the parsed Stmt
parseStmt :: String -> [String] -> Stmt
parseStmt "let" (v:"=":expr) = Let v (parseExpr expr)
parseStmt "print" exprList = Print (parseListExpr exprList)
parseStmt "input" [v] = Input v
parseStmt "if" [expr,goto,label] = If (parseExpr [expr]) label
parseStmt "if" [e1,e2,e3,goto,label] = If (parseExpr [e1,e2,e3]) label
parseStmt first rest = Error (unwords (first:rest))

-- takes a list of tokens, symTable, line number, and returns a tuple of statement and the symtable. 
parseLine :: [String] -> SymTable -> Float -> (Stmt, SymTable)
parseLine (first:rest) env lineNum =
    if (isLabel first) then (parseStmt (head rest) (tail rest), (first,lineNum):env) 
        else (parseStmt first rest, env) 

-- takes a variable name and a ST and returns the value of that variable or zero if the variable is not in the ST
lookupVar :: String -> SymTable -> Float
lookupVar name [] = 0
lookupVar name ((id,v):rest) = if (id == name) then v else lookupVar name rest

-- evaluates the given Expr with the variable values found in the given ST
eval :: Expr ->SymTable -> Float
eval (Var v) env = lookupVar v env
eval (Constant v) _ = v
eval (Plus e1 e2) env = (eval e1 env) + (eval e2 env)
eval (Minus e1 e2) env = (eval e1 env) - (eval e2 env)
eval (Times e1 e2) env = (eval e1 env) * (eval e2 env)
eval (Div e1 e2) env = (eval e1 env) / (eval e2 env)
eval (LT_ e1 e2) env = if ((eval e1 env) < (eval e2 env)) then 1 else 0
eval (GT_ e1 e2) env = if ((eval e1 env) > (eval e2 env)) then 1 else 0
eval (LE_ e1 e2) env = if ((eval e1 env) <= (eval e2 env)) then 1 else 0
eval (GE_ e1 e2) env = if ((eval e1 env) >= (eval e2 env)) then 1 else 0
eval (EQ_ e1 e2) env = if ((eval e1 env) == (eval e2 env)) then 1 else 0
eval (NEQ_ e1 e2) env = if ((eval e1 env) /= (eval e2 env)) then 1 else 0

-- given a statement, a ST, line number, input and previous output, return an updated ST, input, output, and line number
-- if the given statement was not a valid keyword, print error statement.
-- Stmt, SymTable, progCounter, input, output, (SymTable', input', output', progCounter)
perform:: Stmt -> SymTable -> Float -> [String] ->String -> (SymTable, [String], String, Float)
perform (Print e) env lineNum input output = (env, input, (printList e env), lineNum+1)
perform (Let id e) env lineNum input output = ((id,(eval e env)):env, input, output, lineNum+1)
perform (If expr label) st lineNum input output =
    if (eval expr st) /= 0 then (st, input, output, (lookupVar (label ++ ":") st))
        else (st, input, output, (lineNum + 1))
perform (Input id) st lineNum (input:rest) output = ((id, read input):st, rest, output, (lineNum + 1))
perform (Error msg) env lineNum input output = (env, input, ("Error on line " ++ (show lineNum) ++ "\n"++msg++"\n"), -1)

-- given a list of Stmts, a ST, line number and current input and output, perform all of the statements in the list and return the updated output String in IO
run :: [Stmt] -> SymTable -> Float -> [String] -> String -> IO ()
run listOfStmt st lineNum input output = 
    if lineNum <= fromIntegral (length listOfStmt) && lineNum >= 1 then let (st1, input1, output1, nextLine) = perform (listOfStmt !! round (lineNum - 1)) st lineNum input output in
        if output1 == output then run listOfStmt st1 nextLine input1 ""
            else do putStr output1
                    run listOfStmt st1 nextLine input1 output1 
    else return ()

-- given list of list of tokens, a ST, and return the list of parsed Stmts and ST storing mapping of labels to line numbers
-- basically goes through every function that is used in parsing by using parseEveryline
parseTest :: [[String]] -> SymTable -> ([Stmt], SymTable)
parseTest stmt st = parseEveryLine stmt 1.0 st

-- creating a new function to use in parseTest and to use in putStr so that I can still use map
-- to parse every line in the file by using tail recursion.
parseEveryLine :: [[String]] -> Float -> SymTable -> ([Stmt], SymTable)
parseEveryLine [] _ st = ([], st)          --when the list of strings of statements are empty, return the empty list and the symTable
parseEveryLine (curr:rest) lineNum st =
    let (stmt, st1) = parseLine curr st lineNum
        (restStmt, st2) = parseEveryLine rest (lineNum + 1) st1
    in (stmt:restStmt, st2)

-- creating a new function to remove commas from a list of expressions to print, used for ones that print things like: "done", 5.0
-- given a string, remove all commas from the string
removeComma:: String -> String
removeComma xs = [ x | x <- xs, not (x `elem` ",") ]

-- creating a new function to parse list of expressions for correctly parsing the list of expressions to print multiple expressions
-- remove Comma removes unnecessary commas from the list of strings.
-- given a list of strings, return a list of expressions
parseListExpr :: [String] -> [Expr]
parseListExpr [] = []
parseListExpr list = 
    let foldedListExpr = foldl (\a b -> a ++ " " ++ b) "" list
        splitByComma =  words (removeComma foldedListExpr)
        exprList = map words splitByComma
    in map parseExpr exprList

-- creating a new function that prints the list of expressions that are used in keyword "Print"
-- given a list of expressions and symTable, return a string
printList:: [Expr] -> SymTable -> String
printList [] _ = "\n"
printList ((Str string):rest) st = string ++ " " ++ (printList rest st)
printList (e:rest) st = (show (eval e st)) ++ " " ++ (printList rest st)

-- using tail recursion on run to run every parsed line from parseEveryLine
main = do
     args <- getArgs 
     pfile <- openFile (head args) ReadMode
     contents <- hGetContents pfile
     input <- getContents
     let (listOfStmt, st) = parseEveryLine (map words (lines contents)) 1 [] in run listOfStmt st 1 (words input) "" 
     hClose pfile
