#!/usr/bin/env amm
import scala.io.Source

def priority(c: Char) = {
    val asciiCode = c.toInt
    val offset = if (asciiCode >= 97) 96 else 38
    asciiCode - offset
}

val lines = Source.fromFile("03.txt").getLines.toList

{
    print("Part 1: ")
    println(
        lines.map { line =>
            priority(
                line.toList.grouped(line.length / 2).reduce(_ intersect _).head
            )
        }.sum
    )
}

{
    print("Part 2: ")
    println(
        lines.grouped(3).map { group =>
        priority(
                group.map(_.toList).reduce(_ intersect _).head
            )
        }.sum
    )
}
