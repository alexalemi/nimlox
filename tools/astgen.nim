import os, strutils, json
from utils import newLine

# Templates representing Nim constructs
const
  typeDesc = "$1* = ref object of $2"
  propDesc = "$1*: $2"
  caseStmtDesc = "case kind*: $1"
  caseOfDesc = "of $1: $2*: $3"
  caseElseDesc = "else: discard"
  methodDesc = "method accept*[T](expr: $1, v: Visitor): T = return v.visit$1Expression(expr)"

proc addLine(content: var string, line: string="", lineBreak: int=1) =
  if not line.isNilOrEmpty: content.add(line)
  content.add(newLine(count=lineBreak))

proc addImport(content: var string, module: string) =
  content.addLine("import token, literalKind", lineBreak=2)

proc addTypes(content: var string, types: JsonNode) =
  content.addLine("type")
  content.addLine(indent(typeDesc % ["Visitor", "RootObj"], count=2), lineBreak=2)
  content.addLine(indent(typeDesc % ["Expression", "RootObj"], count=2), lineBreak=2)

  for name, obj in pairs(types):
    content.addLine(indent(typeDesc % [name, "Expression"], count=2))
    case obj["type"].str:
      of "regular":
        for prop in obj["props"]:
          content.addLine(indent(propDesc % [prop["name"].str, prop["type"].str], count=4))
      of "case":
        content.addLine(indent(caseStmtDesc % obj["kind"].str, count=4))
        for prop in obj["props"]:
          content.addLine(indent(caseOfDesc % [prop["of"].str, prop["name"].str, prop["type"].str], count=6))
        content.addLine(indent(caseElseDesc, count=6))
    content.addLine()

proc addMethods(content: var string, types: JsonNode) =
  # Method to accomodate visitor pattern
  for param, _ in pairs(types):
    content.addLine(methodDesc % param, lineBreak=2)

proc addAbstractMethod(content: var string) =
  content.addLine("method accept*[T](expr: Expression, v: Visitor): T = quit(\"Overide me\")", lineBreak=2)

proc generateAst(dirName: string) =
  let outputDir = getCurrentDir() / dirName
  echo "Output directory: $1" % outputDir
  discard existsOrCreateDir(outputDir)
  # Different types of expressions in lox language
  let types: JsonNode = %* {
    "Binary": {
      "type": "regular",
      "props": [
        {"name": "left", "type": "Expression"},
        {"name": "operator", "type": "Token"},
        {"name": "right", "type": "Expression"}
      ]
    },
    "Grouping": {
      "type": "regular",
      "props": [{"name": "expression", "type": "Expression"}]
    },
    "Literal": {
      "type": "case",
      "kind": "LiteralKind",
      "props": [
        {"of": "STRING", "name":"sValue", "type": "string"},
        {"of": "NUMBER", "name":"fValue", "type": "float"},
        {"of": "BOOLEAN", "name":"bValue", "type": "bool"},
        {"of": "NIL", "name":"value", "type": "string"},
      ]
    },
    "Unary": {
      "type": "regular",
      "props": [
        {"name": "operator", "type": "Token"},
        {"name": "right", "type": "Expression"}
      ]
    }
  }

  # Core steps to generate `expression.nim`
  var content = ""
  content.addImport("token")
  content.addTypes(types)
  content.addAbstractMethod()
  content.addMethods(types)

  # Finally, write to file
  writeFile(outputDir / "expression.nim", content)

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len != 1:
    quit("Usage: astgen <output directory>")
  generateAst(params[0])
