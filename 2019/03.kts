#!/usr/bin/env kotlin

import java.io.File
import kotlin.math.abs

val wirePaths = File("03.txt").readText().trim().split("\n")

// TODO: Implement something that is not O(n^2)
data class Point(val x: Int, val y: Int)
data class Segment(val start: Point, val end: Point, val length: Int)

val (firstWireSegments, secondWireSegments) = wirePaths.map path@{ path: String ->
    var x = 0
    var y = 0

    return@path path.split(',').map vector@{ vector: String ->
        val direction = vector[0]
        val distance = vector.substring(1).toInt()

        var next_x = x
        var next_y = y
        when (direction) {
            'L' -> { next_x -= distance }
            'R' -> { next_x += distance }
            'U' -> { next_y -= distance }
            'D' -> { next_y += distance }
        }

        val result = Segment(Point(x, y), Point(next_x, next_y), distance)
        x = next_x
        y = next_y
        return@vector result
    }
}

var shortestDistance = Int.MAX_VALUE
var minimumSteps = Int.MAX_VALUE

var firstWireSteps = 0
for (firstWireSegment in firstWireSegments) {
    var secondWireSteps = 0
    for (secondWireSegment in secondWireSegments) {
        // We apparently only have to care when one wire's segment is horizontal and the other wire's is vertical;
        // ignore the potential case where one wire overlaps with the other on a segment.
        listOf(
            firstWireSegment.start,
            firstWireSegment.end,
            secondWireSegment.start,
            secondWireSegment.end,
        ).sortedWith(compareBy({ it.x }, { it.y })).let {
            if (
                it[0].y == it[3].y &&
                it[1].x == it[2].x &&
                it[1].y < it[0].y &&
                it[2].y > it[0].y
            ) {
                // The four points form a diamond, i.e., the left and right points have the same y-value and
                // the top and bottom points have the same x-value. This check is only possible because the segments
                // are either horizontal or vertical.

                val intersectionX = it[1].x
                val intersectionY = it[0].y

                // Part 1
                shortestDistance = minOf(shortestDistance, abs(intersectionX) + abs(intersectionY))

                // Part 2

                // Compute how many steps are needed to go from the beginning of the segment to the intersection
                // for each wire.
                val partialSteps = listOf(
                    intersectionX - firstWireSegment.start.x,
                    intersectionY - firstWireSegment.start.y,
                    intersectionX - secondWireSegment.start.x,
                    intersectionY - secondWireSegment.start.y,
                ).map(::abs).sum()
                minimumSteps = minOf(minimumSteps, firstWireSteps + secondWireSteps + partialSteps)
            }
        }
        secondWireSteps += secondWireSegment.length
    }
    firstWireSteps += firstWireSegment.length
}

println("Part 1: ${shortestDistance}")
println("Part 2: ${minimumSteps}")
