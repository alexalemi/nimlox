import os, strutils

proc display*(msg: string, newLine=true) =
  stdout.write(msg)
  if newLine: stdout.write("\n")

proc isAlpha*(c: char): bool =
  return (c >= 'a' and c <= 'z') or
         (c >= 'A' and c <= 'Z') or
         c == '_'

proc newLine*(count: Natural = 1): string =
  return repeat("\n", count)
