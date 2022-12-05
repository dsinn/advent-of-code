#!/usr/bin/env amm
import scala.collection.mutable.ArrayBuffer
import scala.io.Source

val Array(crateLines, moveLines) = Source.fromFile("05.txt").mkString.split("\n\n")

val stacks = collection.mutable.Map[Int, ArrayBuffer[Char]]()

{
    val crateRegex = "\\[([A-Z])\\]".r

    crateLines.split("\n").foreach { line =>
        crateRegex.findAllMatchIn(line).foreach { mi =>
            val stackNumber = mi.start / 4 + 1
            stacks.getOrElseUpdate(stackNumber, new ArrayBuffer[Char]())
            stacks(stackNumber).addOne(mi.group(1).head)
        }
    }
}

{
    val moveRegex = "^move (\\d+) from (\\d+) to (\\d+)$".r

    val stacks1 = stacks
    val stacks2 = stacks.map { case (k, v) => k -> v.padTo(0, new ArrayBuffer[Char]()) } // Ew, how do Scala deep copy?

    moveLines.split("\n").foreach { line =>
        val List(quantity, source, destination) = moveRegex.findFirstMatchIn(line).get.subgroups.map(_.toInt)

        for (_ <- 1 to quantity) {
            stacks1(destination).prepend(stacks1(source).remove(0))
        }

        for (i <- quantity - 1 to 0 by -1) {
            stacks2(destination).prepend(stacks2(source).remove(i))
        }
    }

    println(s"Part 1: ${stacks1.values.map(_.head).mkString}")
    println(s"Part 2: ${stacks2.values.map(_.head).mkString}")
}
