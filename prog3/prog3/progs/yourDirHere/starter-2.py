# #! /usr/bin/env python3
# import fileinput
# # import re
# import sys

# # used to store a parsed TL expressions which are
# # constant numbers, constant strings, variable names, and binary expressions
# class Expr :
#     def __init__(self, op1, operator, op2=None):
#         self.op1 = op1
#         self.operator = operator
#         self.op2 = op2

#     def __str__(self):
#         if self.op2 == None:    
#             return self.operator + " " + self.op1
#         else:
#             return self.op1 + " " + self.operator + " " +  self.op2

# # evaluate this expression given the environment of the symbol_table
#     def eval(self, symbol_table, line_num):
#         if self.operator == "var":
#             return symbol_table[op1]
#         elif self.operator == "const":
#             return float(self.op1)
#         elif self.operator == "+":
#             return self.op1.eval(symbol_table, line_num) + self.op2.eval(symbol_table, line_num)
#         elif self.operator == "-":
#             return self.op1.eval(symbol_table, line_num) - self.op2.eval(symbol_table, line_num)
#         elif self.operator == "*":
#             return self.op1.eval(symbol_table, line_num) * self.op2.eval(symbol_table, line_num)
#         elif self.operator == "/":
#             return self.op1.eval(symbol_table, line_num) / self.op2.eval(symbol_table, line_num)
#         elif self.operator == "<":
#             return int(self.op1.eval(symbol_table, line_num) < self.op2.eval(symbol_table, line_num))
#         elif self.operator == ">":
#             return int(self.op1.eval(symbol_table, line_num) > self.op2.eval(symbol_table, line_num))
#         elif self.operator == "<=":
#             return int(self.op1.eval(symbol_table, line_num) <= self.op2.eval(symbol_table, line_num))
#         elif self.operator == ">=":
#             return int(self.op1.eval(symbol_table, line_num) >= self.op2.eval(symbol_table, line_num))
#         elif self.operator == "==":
#             return int(self.op1.eval(symbol_table, line_num) == self.op2.eval(symbol_table, line_num))
#         else:
#             print("Operator not found", line_num)
#             sys.exit()

# # used to store a parsed TL statement
# class Stmt:
#     def __init__(self, keyword, exprs):
#         self.keyword = keyword
#         self.exprs = exprs

#     def __str__(self):
#         others = ""
#         for exp in self.exprs:
#             others = others + " " + str(exp)
#         return self.keyword + others

#     def perform(self, symbol_table, program_counter, parsed):
#         if self.keyword == "let":
#             variable = self.exprs[0].op1
#             symbol_table[variable] = self.exprs[1].eval(symbol_table, program_counter)
#         elif self.keyword == "input":
#             variable = self.exprs[0].op1
#             symbol_table[variable] = parsed.read_int()
#         elif self.keyword == "if":
#             bool = self.exprs[0].eval(symbol_table, program_counter)
#             if bool == 0:
#                 return program_counter+1
#             else:
#                 return int(symbol_table[self.exprs[1]])-1   # the -1 is to adjust for zero based indexing of the list
#         elif self.keyword == "print":
#             print_list(self.exprs, symbol_table, program_counter)
#         return program_counter + 1

# def list_to_string(exprs, symbol_table, line_total):
#     i = 0
#     while i < len(exprs):
#         current_expr = exprs[i]
#         if exprs[i].operator == "str":
#             print(exprs[i].op1 + " ")
#         else:
#             print(expr.eval(symbol_table, line_total) + " ")
#         i+=1
#     print ("")

# def parse_expr(tokens, line_total):
#     if len(tokens) == 1:
#         if tokens[0].isdecimal():
#             return Expr(tokens[0], "const")
#         elif tokens[0].isalnum():
#             return Expr(tokens[0], "var")
#         elif tokens[0][0] == '"' and tokens[0][len(tokens[0])-1] == '"':
#             return Expr(tokens[0][1:len(tokens[0]) - 1], "str")
#         else:
#             print("Error on line %s", line_total)
#             sys.exit()
#     elif len(tokens) == 3:
#         return parse_bin_op(tokens, line_total)
#     else:
#         print("Error on line %s", line_total)
#         sys.exit()

# def parse_bin_op(tokens, line_total):
#     if tokens[1] == "+" or tokens[1] == "-" or tokens[1] == "*" or tokens[1] == "/":
#         return Expr(parse_expr([tokens[0]], line_total), tokens[1], parse_expr([tokens[2]], line_total))
#     if tokens[1] == "<" or tokens[1] == ">" or tokens[1] == "<=" or tokens[1] == ">=" or tokens[1] == "==":
#         return Expr(parse_expr([tokens[0]], line_total), tokens[1], parse_expr([tokens[2]], line_total))
#     print("Syntax error on line "+str(line_total)+".")
#     sys.exit()

# def parse_list_expr(line, line_total):
#     split_list = line.split(", ")
#     expr_list = []
#     i = 0
#     while i < len(split_list):
#         trimmed = split_list[i].strip()
#         if trimmed[0] == '"':
#             expr_list.append(parse_expr([trimmed], line_total))
#         else:
#             expr_list.append(parse_expr(trimmed.split(), line_total))
#         i+=1
#     return expr_list

# def parse_stmt(line, line_total, symbol_table):
#     tokens = line.split()
#     if len(tokens) == 0:
#         return Stmt("noop", [])
#     if tokens[0][len(tokens[0]) - 1] == ":":
#         symbol_table[tokens[0][0:len(tokens[0])-1]] = line_num
#         tokens = tokens[1:]
#     elif tokens[0] == "let":
#         return Stmt(tokens[0], [parse_expr([tokens[1]], line_num), parse_expr(tokens[3:], line_num)])
#     elif tokens[0] == "input":
#         return Stmt(tokens[0], [Expr(tokens[1], "var")])
#     elif tokens[0] == "if":
#         return Stmt(tokens[0], [parse_expr(tokens[1 : len(tokens) - 2], line_num), tokens[len(tokens) - 1]])
#     elif tokens[0] == "print":
#         return Stmt(tokens[0], parse_expr_list(line[line.index("print") + 5:], line_total))
#     else:
#         print("Syntax on line %s" + str(line_total) + ".")
#         sys.exit()

# class parser:
#     def __init__(self):
#         self.currentLine = []
#     def read_int(self):
#         if len(self.currentLine) == 0:
#             self.currentLine = input().split()
#         next_line = self.currentLine[0]
#         self.currentLine = self.currentLine[1:]
#         return int(next_line)

# def main():
#     # Create the symbol table
#     symbol_table = {}

#     # Open the file
#     input_file = open(sys.argv[1])

#     # Keep track of line number
#     line_total = 0

#     # This is the line to parse
#     current_parse_line = []

#     # Create a list to hold all statements
#     statement_list = []
#     parsed = parser()

#     # Parse all lines in input
#     # Keep track of line number, input symbols into symbol table
#     for line in input_file: 
#         line_total = line_total + 1
#         stmt = parse_stmt(line, line_total, symbol_table)
#         statement_list.append(stmt)
    
#     program_counter = 0

#     while program_counter < len(statement_list):
#         program_counter = statement_list[program_counter].perform(symbol_table, program_counter, current_parse_line, parsed)

# 	# If the file is not empty keep reading one line
# 	# at a time, till the file is empty
# 	# while line:
# 	    # statement_list.append(line)
# 	    # parsedLine = line.split()
# 	    # print (parsedLine)
# 	    # if parsedLine[len(parsedLine) - 1] == ":":
# 	    #     newStatement = Stmt(newStatement, parsedLine[1], parsedLine[2])
# 	    #     print (newStatement)
# 	    # else:
# 	    #     newStatement = Stmt(newStatement, parsedLine[0]. parsedLine[1])
# 	    #     print (newStatement)

# 	    # if newStatement.keyword = "input"
# 	    # if newStatement.keyword = "let"
# 	    #     newExpression = Expr()
# 	    # if newStatement.keyword = "print"
# 	    # if newStatement.keyword = "if"

# 	    # print(ldine)
# 	    # use realine() to read next line
# 	    # line = file.readline()
# 	# file.close()
# 	# print (statement_list)

# if __name__=="__main__":
# 	main()
#! /usr/bin/env python3
import fileinput
import sys

class Expr :
    def __init__(self, op1, operator, op2=None):
        self.op1 = op1
        self.operator = operator
        self.op2 = op2

    def __str__(self):
        if self.op2 == None:
            return self.operator + " " + self.op1
        else:
            return str(self.op1) + " " + self.operator + " " +  str(self.op2)

    def eval(self, symbol_table, line_number):
        if self.operator == "var":
            return float(symbol_table[self.op1])
        elif self.operator == "const":
            return float(self.op1)
        elif self.operator == "+":
            return self.op1.eval(symbol_table, line_number) + self.op2.eval(symbol_table, line_number)
        elif self.operator == "-":
            return self.op1.eval(symbol_table, line_number) - self.op2.eval(symbol_table, line_number)
        elif self.operator == "*":
            return self.op1.eval(symbol_table, line_number) * self.op2.eval(symbol_table, line_number)
        elif self.operator == "/":
            return self.op1.eval(symbol_table, line_number) / self.op2.eval(symbol_table, line_number)
        elif self.operator == "<":
            return int(self.op1.eval(symbol_table, line_number) < self.op2.eval(symbol_table, line_number))
        elif self.operator == ">":
            return int(self.op1.eval(symbol_table, line_number) > self.op2.eval(symbol_table, line_number))
        elif self.operator == "<=":
            return int(self.op1.eval(symbol_table, line_number) <= self.op2.eval(symbol_table, line_number))
        elif self.operator == ">=":
            return int(self.op1.eval(symbol_table, line_number) >= self.op2.eval(symbol_table, line_number))
        elif self.operator == "==":
            return int(self.op1.eval(symbol_table, line_number) == self.op2.eval(symbol_table, line_number))
        else:
            print("Unexpected operator on line ", line_number)
            sys.exit()

class Stmt :
    def __init__(self, keyword, exprs):
        self.keyword = keyword
        self.exprs = exprs

    def __str__(self):
        others = ""
        for exp in self.exprs:
            others = others + " " + str(exp)
        return self.keyword + others

    def perform(self, symbol_table, program_counter, parsed):
        if self.keyword == "let":
            symbol_table[(self.exprs[0].op1)] = self.exprs[1].eval(symbol_table, program_counter)
        elif self.keyword == "input":
            symbol_table[(self.exprs[0].op1)] = parsed.readInt()
        elif self.keyword == "if":
            bool = self.exprs[0].eval(symbol_table, program_counter)
            if bool == 0:
                return program_counter + 1
            else: 
                return int(symbol_table[self.exprs[1]]) - 1 
        elif self.keyword == "print":
            print_list(self.exprs, symbol_table, program_counter)
        return program_counter + 1

class Parser:
    def __init__(self):
        self.currentLine = []
    def readInt(self):
        if len(self.currentLine) == 0:
            self.currentLine = input().split()
        next = self.currentLine[0]
        self.currentLine = self.currentLine[1:]
        return int(next)

def print_list(exprs, symbol_table, line_number):
    for expr in exprs:
        if expr.operator == "str":
            print(expr.op1, end=" ")
        else:
            print(expr.eval(symbol_table, line_number), end=" ")
    print("")

def parse_expr_list(line, line_number):
    comma_list = line.split(", ")
    expr_list = []
    for expr in comma_list:
        trimmed = expr.strip()
        if trimmed[0] =='"':
            expr_list.append(parse_expr([trimmed], line_number))
        else:
            expr_list.append(parse_expr(trimmed.split(), line_number))
    return expr_list

def parse_expr(tokens, line_number):
    if len(tokens) == 3:
        return Expr(parse_expr([tokens[0]], line_number), tokens[1], parse_expr([tokens[2]], line_number))
    elif len(tokens) == 1:
        if tokens[0].isdecimal():
            return Expr(tokens[0], "const")
        elif tokens[0].isalnum():
            return Expr(tokens[0], "var")
        elif tokens[0][0] == '"' and tokens[0][len(tokens[0])-1] == '"':
            return Expr(tokens[0][1:len(tokens[0])-1], "str")
        else:
            print("Syntax error on line " + str(line_number) + ".")
            sys.exit()
    else:
        print("Syntax error on line " + str(line_number) + ".")
        sys.exit()
    
def parse_statement(line, line_num, symbol_table):
    tokens = line.split()
    if len(tokens) == 0:
        return Stmt("noop", [])
    if tokens[0][len(tokens[0])-1] == ":":
        symbol_table[tokens[0][0:len(tokens[0])-1]] = line_num  
        tokens = tokens[1:]
    if tokens[0]=="let":
        return Stmt(tokens[0], [ parse_expr([tokens[1]], line_num), parse_expr(tokens[3:], line_num)])
    elif tokens[0] == "if":
        numTokens = len(tokens)
        return Stmt(tokens[0], [parse_expr(tokens[1:numTokens-2], line_num), tokens[numTokens-1]])
    elif tokens[0] == "input":
        return Stmt(tokens[0], [Expr(tokens[1], "var")])
    elif tokens[0] == "print":
        return Stmt(tokens[0], parse_expr_list(line[(line.index("print"))+5:], line_num))
    else:
        print("Syntax error on line " + str(line_num) + ".")
        sys.exit()

def main():
	# Open and read in file
    file = open(sys.argv[1])

    # Parse input file
    parsed = Parser()

    # Declarations & initializers 
    symbol_table = {}
    statement_list = []
    line_num = 0

    # Loop through each line in input file and parse each statement
    # Also count number of lines in file
    # Input into symbol table
    for line in file:
        line_num = line_num + 1
        stmt = parse_statement(line, line_num, symbol_table)
        statement_list.append(stmt)
   
    program_counter = 0

    while program_counter < len(statement_list):
        program_counter = statement_list[program_counter].perform(symbol_table, program_counter, parsed)

if __name__=="__main__":
	main()