#!/usr/bin/env amm
import scala.collection.mutable.Set
import scala.io.Source

val maxCoordinate = 4000000

val beacons = Set[(Int, Int)]()

val sensorsAndDist = Source.fromFile("15.txt").getLines.map { line =>
    val mi = "^Sensor at x=(-?\\d+), y=(-?\\d+): closest beacon is at x=(-?\\d+), y=(-?\\d+)$".r.findFirstMatchIn(line).get
    val sensor = (mi.group(1).toInt, mi.group(2).toInt)
    val beacon = (mi.group(3).toInt, mi.group(4).toInt)
    val distance = (sensor._1 - beacon._1).abs + (sensor._2 - beacon._2).abs

    beacons.addOne(beacon)
    (sensor, distance)
}.toSeq

{
    print("Part 1: ")

    // TODO: This needs major optimization because I thought you could union ranges
    // Now my part 2 is orders of magnitude faster than part 1
    val y = maxCoordinate / 2
    val xUnion = Set[Int]()

    sensorsAndDist.foreach { case (sensor, beaconDist) =>
        val yDist = (sensor._2 - y).abs
        val offset = beaconDist - yDist
        xUnion ++= (sensor._1 - offset to sensor._1 + offset).toSet
    }

    println((xUnion.map((_, y)).diff(beacons)).size)
}

{
    print("Part 2: ")

    // Each beacon's range is square-shaped at a 45-degree angle

    // Note: This doesn't solve the _general_ case, but because we're told that there's only one possible place
    // for the distress signal, it's very likely on the intersection of sensor ranges with opposite slopes.
    // My prayers worked.
    val slashBorders = sensorsAndDist.flatMap { case (sensor, dist) =>
        Seq(
            ((sensor._1 - dist - 1, sensor._2), (sensor._1, sensor._2 - dist - 1)), // Left to top
            ((sensor._1 + dist + 1, sensor._2), (sensor._1, sensor._2 + dist + 1)), // Right to bottom
        )
    }
    val backslashBorders = sensorsAndDist.flatMap { case (sensor, dist) =>
        Seq(
            ((sensor._1 - dist - 1, sensor._2), (sensor._1, sensor._2 + dist + 1)), // Left to bottom
            ((sensor._1 + dist + 1, sensor._2), (sensor._1, sensor._2 - dist - 1)), // Right to top
        )
    }

    val range = 0 to maxCoordinate

    for (slash <- slashBorders; backslash <- backslashBorders) {
        val segments = Array(slash, backslash)

        // TODO: Don't recompute the y and b in y = mx + b at each iteration
        val slopes = segments.map { case (start, end) => (end._2 - start._2).signum * (end._1 - start._1).signum }
        val b = segments.zipWithIndex.map { case ((start, _end), i) => start._2 - slopes(i) * start._1 }
        val x = (b(1) - b(0)) / (slopes(0) - slopes(1))
        val y = slopes(0) * x + b(0)

        if (range.contains(x) && range.contains(y) && segments.forall { case (start, end) =>
            start._1.min(end._1) <= x && x <= start._1.max(end._1) &&
            start._2.min(end._2) <= y && y <= start._2.max(end._2)
        } && sensorsAndDist.forall { case (sensor, dist) =>
            (sensor._1 - x).abs + (sensor._2 - y).abs > dist
        }) {
            println(s"(${x}, ${y}) -> ${x.toLong * 4000000 + y}")
            System.exit(0)
        }
    }
}
