#!/usr/bin/env amm
import scala.io.Source
import scala.util.matching.Regex.Match

val cache = collection.mutable.Map[String, Long]()
val monkeys = collection.mutable.Map[String, () => Long]()
val exprs = collection.mutable.Map[String, String]()

def monkeyEval(monkey: String): Long = {
    if (cache.contains(monkey)) return cache(monkey)

    val result = monkeys(monkey).apply
    cache.put(monkey, result)
    result
}

Source.fromFile("21.txt").getLines.foreach { line =>
    val mi = "^([a-z]+): *(.+)$".r.findFirstMatchIn(line).get
    val monkey = mi.group(1)
    val expr = mi.group(2)

    val fun = if (expr.matches("-?\\d+")) {
        exprs.put(monkey, expr)
        () => { expr.toLong }
    } else {
        exprs.put(monkey, s"(${expr})")
        val tokens = expr.split(" ")
        val operands = Seq(0, 2).map { i => () => monkeyEval(tokens(i)) }

        tokens(1) match {
            case "+" => () => operands(0).apply + operands(1).apply
            case "-" => () => operands(0).apply - operands(1).apply
            case "*" => () => operands(0).apply * operands(1).apply
            case "/" => () => operands(0).apply / operands(1).apply
            case _ => throw new RuntimeException(s"Unknown operator \"${tokens(1)}\"")
        }
    }

    monkeys.put(monkey, fun)
}

println(s"Part 1: ${monkeyEval("root")}")

print("Part 2: ")

// I know all the string <-> int conversion is slow, but regexes are more fun than television.

def rawEquation(): String = {
    // I'm sorry, is this a terrible pun that would confuse people with case sensitivity?
    val monKeys = s"\\b${(monkeys.keySet -- Set("root", "humn")).mkString("|")}\\b".r

    var expr = exprs("root").replaceFirst("[+-\\\\*/]", "=")
    while (true) {
        val newExpr = monKeys.replaceAllIn(expr, m => exprs(m.group(0)))
        if (newExpr == expr) {
            return expr.replaceFirst("^\\((.+)\\)$", "$1").replace("humn", "x")
        }

        expr = newExpr
    }
    "THIS"
}

def simplify(expr: String): String = {
    var bleh = expr
    while (true) {
        var newExpr = "\\((-?\\d+)\\)".r.replaceAllIn(bleh, "$1")
        newExpr = "(?<!\\d)(-?\\d+) ([\\*/]) (-?\\d++)".r.replaceAllIn(newExpr, (m: Match) => (m.group(2) match {
            case "*" => m.group(1).toLong * m.group(3).toLong
            case "/" => m.group(1).toLong / m.group(3).toLong
        }).toString)
        newExpr = "(?<!\\d)(-?\\d+) ([+-]) (-?\\d++)".r.replaceAllIn(newExpr, (m: Match) => (m.group(2) match {
            case "+" => m.group(1).toLong + m.group(3).toLong
            case "-" => m.group(1).toLong - m.group(3).toLong
        }).toString)

        if (newExpr == bleh) {
            return bleh
        }
        bleh = newExpr
    }
    "IS"
}

def doAlgebra(expr: String): String = {
    var bleh = expr.replaceFirst("(-?\\d+) = ([^x]*+x.*)$", "$2 = $1") // In case the x is on the right side

    while (true) {
        var newExpr = bleh.replaceFirst("^\\(([^=]+)\\) =", "$1 =")
        newExpr = "^(-?\\d+) ([+-\\\\*]) ([^=]*) = (.+)$".r.replaceAllIn(newExpr, (m: Match) => {
            val Seq(left, right) = Seq(1, 4).map { i => m.group(i).toLong }
            m.group(2) match {
                case "+" => s"${m.group(3)} = ${right - left}"
                case "-" => s"${m.group(3)} = ${left - right}"
                case "*" => s"${m.group(3)} = ${right / left}"
            }
        })
        newExpr = "([+-\\\\*/]) (-?\\d+) = (.+)$".r.replaceAllIn(newExpr, (m: Match) => {
            val Seq(left, right) = Seq(2, 3).map { i => m.group(i).toLong }
            m.group(1) match {
                case "+" => s"= ${right - left}"
                case "-" => s"= ${right + left}"
                case "*" => s"= ${right / left}"
                case "/" => s"= ${right * left}"
            }
        })

        if (newExpr == bleh) {
            return bleh.replaceFirst("^x = ", "")
        }
        bleh = newExpr
    }
    "DUMB"
}

println(doAlgebra(simplify(rawEquation)))
