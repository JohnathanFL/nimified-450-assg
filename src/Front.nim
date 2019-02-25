import strutils # isAlpha, isDigit

type
  Token{.pure.} = enum
    INT_LIT
    IDENT
    ASSIGN_OP
    ADD_OP
    SUB_OP
    MULT_OP
    DIV_OP
    LEFT_PAREN
    RIGHT_PAREN
    EOF
  CharClass{.pure.} = enum 
    LETTER, DIGIT, UNKNOWN, EOF

var lexeme: string = ""
var charClass: CharClass
var nextChar: char
var lexLen: uint
var token: Token
var nextToken: Token
var file: File

proc addChar() =
  lexeme.add(nextChar)

proc lookup(ch: char): Token =
  addChar()
  case ch:
    of '(':
      nextToken = Token.LEFT_PAREN
    of ')':
      nextToken = Token.RIGHT_PAREN
    of '+':
      nextToken = Token.ADD_OP
    of '-':
      nextToken = Token.SUB_OP
    of '*':
      nextToken = Token.MULT_OP
    of '/':
      nextToken = Token.DIV_OP
    else:
      nextToken = Token.EOF

proc getChar() =
  if not file.endOfFile:
    nextChar = file.readChar()
    if nextChar.isAlpha:
      charClass = CharClass.LETTER
    elif nextChar.isDigit:
      charClass = CharClass.DIGIT
    else:
      charClass = CharClass.UNKNOWN
  else: charClass = CharClass.EOF

proc getNonBlank() =
  while (not file.endOfFile) and nextChar.isSpace:
    getChar()

proc lex(): Token =
  lexeme = ""
  getNonBlank()
  case charClass:
    of CharClass.LETTER:
      addChar()
      getChar()
      while charClass == CharClass.LETTER or charClass == CharClass.DIGIT:
        addChar()
        getChar()
      nextToken = Token.IDENT
    of CharClass.DIGIT:
      addChar()
      getChar()
      while charClass == CharClass.DIGIT:
        addChar()
        getChar()
      nextToken = Token.INT_LIT
    of CharClass.UNKNOWN:
      discard lookup(nextChar)
      getChar()
    of CharClass.EOF:
      nextToken = Token.EOF
      lexeme = "EOF"
  echo "Next token is: ", $nextToken, ", next lexeme is ", lexeme
  return nextToken

if isMainModule:
  if not file.open("front.in"):
    echo "ERROR - cannot open front.in"
    quit(-1)

  getChar()
  while nextToken != Token.EOF:
    discard lex()