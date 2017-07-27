import strutils

type
  TokenType* = enum
    # Single-character tokens.
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,
    # One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,
    # Literals.
    IDENTIFIER,
    STRING,
    NUMBER,
    # Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,
    EOF

  Token* = object
    tokenType*: TokenType
    lexeme*, literal*: string
    line*: int

# Stringify token
proc `$`*(t: Token): string =
  return "$1 $2 $3" % [$t.tokenType, t.lexeme, t.literal]