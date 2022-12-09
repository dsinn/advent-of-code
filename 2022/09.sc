#!/usr/bin/env amm
import scala.io.Source

val lines = Source.fromFile("09.txt").getLines.toList

def calcUniqueTailPositions(lines: Seq[String], knots: Int): Int = {
    val knotsPos = Array.fill(knots) { Array(0, 0) }
    val tailPosSet = collection.mutable.Set[String]()

    lines.foreach { line =>
        val Array(dir, stepsString) = line.split(" ")
        val steps = stepsString.toInt
        val headPos = knotsPos.head

        val nextHeadPosRange = dir match {
            case "L" => (headPos(1) - 1 to headPos(1) - steps by -1).map((headPos(0), _))
            case "R" => (headPos(1) + 1 to headPos(1) + steps).map((headPos(0), _))
            case "U" => (headPos(0) - 1 to headPos(0) - steps by -1).map((_, headPos(1)))
            case "D" => (headPos(0) + 1 to headPos(0) + steps).map((_, headPos(1)))
            case _ => throw new RuntimeException(s"Unknown direction \"${dir}\"")
        }

        nextHeadPosRange.foreach { nextHeadPos =>
            knotsPos.head(0) = nextHeadPos._1
            knotsPos.head(1) = nextHeadPos._2

            for (i <- 1 until knots) {
                val gaps = (0 to 1).map { axis => knotsPos(i - 1)(axis) - knotsPos(i)(axis) }
                if (gaps.exists(_.abs > 1)) {
                    gaps.zipWithIndex.foreach {
                        case (gap, axis) => knotsPos(i)(axis) += gap.signum
                    }
                }
            }

            tailPosSet.add(knotsPos.last.mkString(","))
        }
    }

    tailPosSet.size
}

println(s"Part 1: ${calcUniqueTailPositions(lines, 2)}")
println(s"Part 2: ${calcUniqueTailPositions(lines, 10)}")
