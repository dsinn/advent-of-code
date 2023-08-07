#!/usr/bin/env amm
import scala.io.Source

val Array(part1, part2) = Source.fromFile("04.txt").getLines.foldLeft(Array(0, 0))((parts, line) => {
    val sections = "\\D+".r.split(line).map(_.toInt)

    if (sections(0) <= sections(2) && sections(3) <= sections(1)
            || sections(2) <= sections(0) && sections(1) <= sections(3)) {
        parts(0) += 1
    }

    if (sections(0) <= sections(2) && sections(2) <= sections(1)
            || sections(2) <= sections(0) && sections(0) <= sections(3)) {
        parts(1) += 1
    }

    parts
})

println(s"Part 1: ${part1}")
println(s"Part 2: ${part2}")
