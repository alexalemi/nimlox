import os, strutils, json
from utils import newLine

# Templates representing Nim constructs
const
  importDesc = "import $1"
  typeDesc = "$1* = ref object of $2"
  propDesc = "$1*: $2"
  caseStmtDesc = "case kind*: $1"
  caseOfDesc = "of $1: $2*: $3"
  caseElseDesc = "else: discard"

proc addLine(content: var string, line: string="", lineBreak: int=1) =
  if not line.isNilOrEmpty: content.add(line)
  content.add(newLine(count=lineBreak))

proc addImport(content: var string, modules: string) =
  content.addLine(importDesc % modules, lineBreak=2)

proc addTypes(content: var string, types: JsonNode) =
  content.addLine("type")

  for name, obj in pairs(types):
    content.addLine(indent(typeDesc % [name, obj["extendFrom"].str], count=2))
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

proc generateAst(dirName: string) =
  let outputDir = getCurrentDir() / dirName
  echo "Output directory: $1" % outputDir
  discard existsOrCreateDir(outputDir)
  # Different types of expressions in lox language
  let types: JsonNode = %* {
    "Expression": {
      "type": "regular",
      "extendFrom": "RootObj",
      "props": [
        {"name": "hasError", "type": "bool"},
      ]
    },
    "Binary": {
      "type": "regular",
      "extendFrom": "Expression",
      "props": [
        {"name": "left", "type": "Expression"},
        {"name": "operator", "type": "Token"},
        {"name": "right", "type": "Expression"}
      ]
    },
    "Grouping": {
      "type": "regular",
      "extendFrom": "Expression",
      "props": [{"name": "expression", "type": "Expression"}]
    },
    "Literal": {
      "type": "case",
      "extendFrom": "Expression",
      "kind": "LiteralKind",
      "props": [
        {"of": "litString", "name":"strVal", "type": "string"},
        {"of": "litNumber", "name":"floatVal", "type": "float"},
        {"of": "litBool", "name":"boolVal", "type": "bool"},
      ]
    },
    "Unary": {
      "type": "regular",
      "extendFrom": "Expression",
      "props": [
        {"name": "operator", "type": "Token"},
        {"name": "right", "type": "Expression"}
      ]
    }
  }

  # Core steps to generate `expression.nim`
  var content = ""
  content.addLine("# autogenerated via tools/astgen.nim", lineBreak=2)
  content.addImport("token, literalKind")
  content.addTypes(types)

  # Finally, write to file
  writeFile(outputDir / "expression.nim", content)

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len != 1:
    quit("Usage: astgen <output directory>")
  generateAst(params[0])
