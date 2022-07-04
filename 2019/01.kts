#!/usr/bin/env kotlin

import java.io.File

val masses: List<Int> = File("01.txt").readLines().map { it.toInt() }

println("Part 1: ${masses.sumOf { it / 3 - 2 }}")

fun pt2cost(mass: Int, cache: MutableMap<Int, Int>): Int {
    return cache.getOrPut(mass) {
        val firstOrderFuel = mass / 3 - 2
        firstOrderFuel.let { if (it <= 0) 0 else it + pt2cost(it, cache) }
    }
}

val pt2cache = mutableMapOf<Int, Int>()
println("Part 2: ${masses.sumOf { pt2cost(it, pt2cache) }}")
