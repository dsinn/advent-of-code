#!/usr/bin/env amm
import scala.collection.mutable.ListBuffer
import scala.io.Source

/**
  * Given a file of at most 40 characters and 6 lines, prints an input file such that when run with your AoC solution,
  * your program outputs the # characters in the same places.
  *
  * @param
  * @param filePath The path to the file
  */
@main
def main(filePath: String) = {
    Source
        .fromFile(filePath)
        .mkString
        .split("\n")
        .zip(LazyList.from(1))
        .map { case (line, i) =>
            val paddedLine = if (line.length > 40) {
                System.err.println(s"Warning: Line ${i} exceeds 40 characters, so it will be truncated.")
                line.substring(0, 40)
            } else {
                line.padTo(40, ' ')
            }
            paddedLine.toSeq.map(_ == '#')
        }
        .flatten
        .grouped(2)
        .zipWithIndex
        .drop(1)
        .foldLeft(1) { case (x, (group, cyclePair)) => {
            val target = (cyclePair * 2 + (group match {
                case Array(true, true) => 0
                case Array(true, false) => -1
                case Array(false, true) => 2
                case Array(false, false) => -2
             }) + 1) % 40 - 1

            println(s"addx ${target - x}")

            target
        }}
    println("noop")
    println("noop")
}
