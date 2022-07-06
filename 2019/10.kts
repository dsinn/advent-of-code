#!/usr/bin/env kotlin

import java.io.File
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.PI
import kotlin.math.sign

val rows = File("10.txt").readLines()
val height = rows.size
val width = rows[0].length

val asteroids = rows.flatMapIndexed { i, row ->
    "#"
        .toRegex()
        .findAll(row)
        .flatMap { result -> result.groups.map { group -> group!!.range.first } }
        .map { j -> Vector2D(j, i) }
}.toSet()

data class Vector2D(val x: Int, val y: Int) {
    operator fun minus(v2: Vector2D) = Vector2D(x - v2.x, y - v2.y)
    operator fun plus(v2: Vector2D) = Vector2D(x + v2.x, y + v2.y)
}

fun gcd(a: Int, b: Int): Int {
    return if (a == 0) b else gcd(b % a, a)
}

fun getVisibleAsteroids(station: Vector2D, asteroids: Set<Vector2D>): Set<Vector2D> {
    val visibleAsteroids = asteroids.toMutableSet()
    visibleAsteroids.remove(station)

    asteroids.forEach { asteroid ->
        val offset = asteroid - station

        val isHorizontal = offset.y == 0
        val isVertical = offset.x == 0

        val step: Vector2D = when {
            isHorizontal && isVertical -> { // This is the station we're checking
                return@forEach
            }
            isHorizontal -> Vector2D(offset.x.sign, 0) // Everything to the left/right of this asteroid is blocked
            isVertical -> Vector2D(0, offset.y.sign) // Everything above/below this asteroid is blocked
            else -> { // Diagonal line of sight logic
                val gcd = abs(gcd(offset.x, offset.y))
                Vector2D(offset.x / gcd, offset.y / gcd)
            }
        }

        var blockedPoint = asteroid + step
        while (blockedPoint.x in (0 until width) && blockedPoint.y in (0 until height)) {
            visibleAsteroids.remove(blockedPoint)
            blockedPoint += step
        }
    }

    return visibleAsteroids
}

val bestStationPair = asteroids.map { station ->
    station to getVisibleAsteroids(station, asteroids).size
}.maxBy { it.second }

val bestStation: Vector2D = bestStationPair.first

println("Part 1: ${bestStationPair.second}")

val TARGET_ASTEROID_INDEX = 198 // 0-index and...something, but it works!

var remainingAsteroids = asteroids.toSet()
var asteroidsLasered = 0
while (asteroidsLasered < TARGET_ASTEROID_INDEX) {
    val visibleAsteroids = getVisibleAsteroids(bestStation, remainingAsteroids)
    val newAsteroidsLasered = asteroidsLasered + visibleAsteroids.size

    if (newAsteroidsLasered >= TARGET_ASTEROID_INDEX) {
        val targetAsteroidLocalIndex = TARGET_ASTEROID_INDEX - asteroidsLasered
        val targetAsteroid = visibleAsteroids.sortedBy { asteroid ->
            // The y-axis increases in the direction opposite to our model, ugh.
            val offset = Vector2D(asteroid.x - bestStation.x, -(asteroid.y - bestStation.y))
            // atan2's result is with respect to the x-axis, but we need the y-axis to be first in the order
            -(atan2(offset.y.toDouble(), offset.x.toDouble()) + 3.5 * PI) % (2 * PI)
        }[targetAsteroidLocalIndex]

        targetAsteroid.let { println("Part 2: ${100 * it.x + it.y}") }
    }

    remainingAsteroids = remainingAsteroids subtract visibleAsteroids
    asteroidsLasered = newAsteroidsLasered
}
