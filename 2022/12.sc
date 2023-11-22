#!/usr/bin/env amm
import scala.io.Source
import scala.collection.mutable.Queue
import scala.util.control.Breaks.{break, breakable}

val elevationA = 'a'.toInt

var start, end = (-1, -1)

val heightMap = Source.fromFile("12.txt").mkString.split("\n").zipWithIndex.map {
    case (line, i) => line.toArray.zipWithIndex.map {
        case (char, j) => char match {
            case 'S' => {
                start = (i, j)
                elevationA
            }
            case 'E' => {
                end = (i, j)
                'z'.toInt
            }
            case _ => char.toInt
        }
    }
}

val visited = Array.ofDim[Boolean](heightMap.length, heightMap.head.length)
var elevationADistance = Int.MaxValue

// Breadth-first search
var distance = 0
var queue = Queue(end)

breakable {
    while (true) {
        for (_ <- queue.size to 1 by -1) {
            val (i, j) = queue.dequeue

            if (heightMap(i)(j) == elevationA) {
                elevationADistance = elevationADistance.min(distance)

                if ((i, j) == start) {
                    println(s"Part 1: ${distance}")
                    break
                }
            }

            Seq((i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1)).foreach { case (ni, nj) =>
                try {
                    if (!visited(ni)(nj) && (heightMap(i)(j) - heightMap(ni)(nj)) <= 1) {
                        visited(ni)(nj) = true
                        queue += ((ni, nj))
                    }
                } catch {
                    case e: ArrayIndexOutOfBoundsException => { }
                    case e: Throwable => throw e
                }
            }
        }

        distance += 1
    }
}

println(s"Part 2: ${elevationADistance}")
