#!/usr/bin/env kotlin

import java.io.File
import kotlin.math.abs
import kotlin.math.sign

val positionsByMoon = File("12.txt")
    .readLines()
    .map { line -> """-?\d++""".toRegex().findAll(line) }
    .map { matches -> matches.map { match -> match.value.toInt() }.toList() }

data class Vector3D(var x: Int, var y: Int, var z: Int) {
    operator fun minus(v2: Vector3D) = Vector3D(x - v2.x, y - v2.y, z - v2.z)
    operator fun plus(v2: Vector3D) = Vector3D(x + v2.x, y + v2.y, z + v2.z)
}

data class Moon(val pos: Vector3D, val vel: Vector3D)

val moons = positionsByMoon.map { Moon(Vector3D(it[0], it[1], it[2]), Vector3D(0, 0, 0)) }

fun serializedState(moons: List<Moon>): String {
    return moons
        .map { moon -> listOf(moon.pos, moon.vel).map { v -> "${v.x},${v.y},${v.z}" }.joinToString(";") }
        .joinToString("M")
}

fun simulateStep(moons: List<Moon>) {
    // Speed calculations
    for (i in moons.indices) {
        for (j in i + 1 until moons.size) {
            val moon1 = moons[i]
            val moon2 = moons[j]

            val xOffset = (moon2.pos.x - moon1.pos.x).sign
            val yOffset = (moon2.pos.y - moon1.pos.y).sign
            val zOffset = (moon2.pos.z - moon1.pos.z).sign

            moon1.vel.x += xOffset
            moon1.vel.y += yOffset
            moon1.vel.z += zOffset

            moon2.vel.x -= xOffset
            moon2.vel.y -= yOffset
            moon2.vel.z -= zOffset
        }
    }

    // Position calculations
    moons.forEach { moon ->
        moon.pos.x += moon.vel.x
        moon.pos.y += moon.vel.y
        moon.pos.z += moon.vel.z
    }
}

(1..1000).forEach { simulateStep(moons) }

fun computeEnergy(moon: Moon): Int {
    return listOf(moon.pos, moon.vel)
        .map { v -> listOf(v.x, v.y, v.z).map { abs(it) } }
        .map { it.sum() }
        .reduce(Int::times)
}

println("Part 1: ${moons.map { moon -> computeEnergy(moon) }.sum()}")

// Part 2 - Since each axis is independent, compute their periods individually and then find the lowest common multiple.

// While I could've switched part 1 to use the independent axis calculations below, its explicit "all moons in one step"
// model is rather easy to follow and is fine for what it was meant to do.

class Axis(val pos: MutableList<Int>, val vel: MutableList<Int>) {
    fun serialize(): String {
        return listOf(pos, vel)
            .map { v -> v.joinToString(",") }
            .joinToString(";")
    }
}

val axes = listOf(
    positionsByMoon.map { it[0] },
    positionsByMoon.map { it[1] },
    positionsByMoon.map { it[2] },
).map { pos -> Axis(pos.toMutableList(), MutableList(pos.size) { 0 }) }

fun computePeriod(axis: Axis): Int {
    val states: MutableSet<String> = mutableSetOf()

    var step = 0
    var state = axis.serialize()
    while (state !in states) {
        states.add(state)

        // Speed calculations
        for (i in axis.pos.indices) {
            for (j in i + 1 until axis.pos.size) {
                val offset = (axis.pos[j] - axis.pos[i]).sign
                axis.vel[i] += offset
                axis.vel[j] -= offset
            }
        }

        // Position calculations
        for (i in axis.pos.indices) {
            axis.pos[i] += axis.vel[i]
        }

        step++
        state = axis.serialize()
    }

    return step
}

val periods = axes.map { axis -> computePeriod(axis) }

fun gcd(a: Long, b: Long): Long {
    return if (a == 0L) b else gcd(b % a, a)
}

fun lcm(a: Long, b: Long): Long {
    return (a * b) / gcd(a, b)
}

val lcm = periods.map { it.toLong() }.reduce { a, b -> lcm(a, b) }

println("Part 2: ${lcm}")
