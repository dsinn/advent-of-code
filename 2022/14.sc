#!/usr/bin/env amm
import scala.collection.mutable.Set
import scala.io.Source

def findStopLocation(x: Int, y: Int, yMax: Int, occupied: Set[(Int, Int)]): (Int, Int) = {
    if (y >= yMax) return (x, y)
    val nextX = findAdjacentFreeSpace(x, y, occupied)
    if (nextX.isEmpty) return (x, y)
    return findStopLocation(nextX.get, y + 1, yMax, occupied)
}

def findAdjacentFreeSpace(x: Int, y: Int, occupied: Set[(Int, Int)]): Option[Int] = {
    Seq(x, x - 1, x + 1).foreach { nextX =>
        if (!occupied.contains((nextX, y + 1))) return Option(nextX)
    }
    None
}

def countSand(occupied: Set[(Int, Int)], yMax: Int, stopCondition: ((Int, Int), Int) => Boolean): Int = {
    LazyList.from(0).foreach { count =>
        val nextSandLocation = findStopLocation(500, 0, yMax, occupied)
        if (stopCondition(nextSandLocation, yMax)) return count
        occupied.addOne(nextSandLocation)
    }
    -1
}

Seq(
    (sand: (Int, Int), yMax: Int) => sand._2 == yMax,
    (sand: (Int, Int), _yMax: Int) => sand == (500, 0)
).zip(LazyList.from(1)).foreach { case (stopCondition, part) =>
    val occupied = Source.fromFile("14.txt").getLines.flatMap { line =>
        val waypoints = line.split(" -> ").map(_.split(",").map(_.toInt))

        waypoints.sliding(2, 1).flatMap { case Array(start, end) =>
            (for (
                x <- (start(0) min end(0)) to (start(0) max end(0));
                y <- (start(1) min end(1)) to (start(1) max end(1))
            ) yield (x, y)).toList
        }
    }.to(Set)

    val yMax = occupied.map(_._2).max + 1
    println(s"Part ${part}: ${countSand(occupied, yMax, stopCondition) + (part - 1)}")
}
