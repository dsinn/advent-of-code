#!/usr/bin/env amm
import scala.io.Source

val caloriesByElf = Source.fromFile("01.txt").mkString.split("\n\n").map(
    _.split("\n").map(_.toInt).sum
)

println(s"Part 1: ${caloriesByElf.max}")
println(s"Part 2: ${caloriesByElf.sorted.reverse.take(3).sum}")
