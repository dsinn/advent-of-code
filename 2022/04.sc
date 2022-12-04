#!/usr/bin/env amm
import scala.io.Source

var part1, part2 = 0

Source.fromFile("04.txt").getLines.foreach { line =>
    val sections = "\\D+".r.split(line).map(_.toInt)

    if (sections(0) <= sections(2) && sections(3) <= sections(1)
            || sections(2) <= sections(0) && sections(1) <= sections(3)) {
        part1 += 1
    }

    if (sections(0) <= sections(2) && sections(2) <= sections(1)
            || sections(2) <= sections(0) && sections(0) <= sections(3)) {
        part2 += 1
    }
}

println(s"Part 1: ${part1}")
println(s"Part 2: ${part2}")
