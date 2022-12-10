#!/usr/bin/env amm
import scala.io.Source

var cycle, x = 1
val addOperands = collection.mutable.Map[Int, Int]()
var signalStrength = 0
var nextLineCycle = -1

val lineIterator = Source.fromFile("10.txt").getLines
val frameBuffer = new StringBuilder()

while (lineIterator.hasNext) {
    x += addOperands.remove(cycle).getOrElse(0)

    if (cycle % 40 == 20 && cycle <= 220) {
        signalStrength += cycle * x
    }

    if (nextLineCycle <= cycle) {
        val line = lineIterator.next
        nextLineCycle = cycle + (line match {
            case "noop" => 1
            case _ => {
                addOperands.put(cycle + 2, line.substring(line.lastIndexOf(" ") + 1).toInt)
                2
            }
        })
    }

    frameBuffer.append(if ((x - (cycle - 1) % 40).abs <= 1) "#" else ".")

    cycle += 1
}

println(s"Part 1: ${signalStrength}")

println(s"Part 2:")
println(".{40}".r.replaceAllIn(frameBuffer.mkString, "$0\n"))
