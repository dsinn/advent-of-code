#!/usr/bin/env amm
import scala.io.Source

val part1Points = Map(
    "A X" -> 4,
    "A Y" -> 8,
    "A Z" -> 3,
    "B X" -> 1,
    "B Y" -> 5,
    "B Z" -> 9,
    "C X" -> 7,
    "C Y" -> 2,
    "C Z" -> 6,
)

val part2Points = Map(
    "A X" -> 3,
    "A Y" -> 4,
    "A Z" -> 8,
    "B X" -> 1,
    "B Y" -> 5,
    "B Z" -> 9,
    "C X" -> 2,
    "C Y" -> 6,
    "C Z" -> 7,
)

var part1, part2 = 0

Source.fromFile("02.txt").getLines.foreach { line =>
    part1 += part1Points(line)
    part2 += part2Points(line)
}

println(s"Part 1: ${part1}")
println(s"Part 2: ${part2}")
