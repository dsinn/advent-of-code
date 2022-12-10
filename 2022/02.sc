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

Source.fromFile("02.txt").getLines.foldLeft(Array(0, 0))((answers, line) => {
    answers(0) += part1Points(line)
    answers(1) += part2Points(line)
    answers
}).zip(LazyList.from(1)).foreach { case (answer, part) =>
    println(s"Part ${part}: ${answer}")
}
