# autogenerated via tools/astgen.nim

import token, literalKind, expr

type
  Stmt* = ref object of RootObj
    hasError*: bool

  Expression* = ref object of Stmt
    expression*: Expr

  Print* = ref object of Stmt
    expression*: Expr
