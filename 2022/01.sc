#!/usr/bin/env amm
import scala.io.Source

val caloriesByElf = Source.fromFile("01.txt").mkString.split("\n\n").map(
    _.split("\n").map(_.toInt).sum
).sorted.reverse

println(s"Part 1: ${caloriesByElf.head}")
println(s"Part 2: ${caloriesByElf.take(3).sum}")
