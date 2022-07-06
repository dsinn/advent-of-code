#!/usr/bin/env kotlin

import java.io.File

// orbiter -> orbitee
val orbits = File("06.txt").readLines().associate { line -> line.split(")").let { obj -> obj[1] to obj[0] } }

fun computeDistanceFromCentre (orbiter: String, distances: MutableMap<String, Int>, orbits: Map<String, String>): Int {
    return distances.getOrPut(orbiter) {
        if (!orbits.containsKey(orbiter)) {
            // This is the centre (COM)
            return@getOrPut 0
        }

        val orbitee = orbits.getValue(orbiter)
        computeDistanceFromCentre(orbitee, distances, orbits) + 1
    }
}

val distances: MutableMap<String, Int> = mutableMapOf()
orbits.keys.forEach { computeDistanceFromCentre(it, distances, orbits) }
println("Part 1: ${distances.values.sum()}")

// Since the system is a single tree, we can compute the number of orbital transfers based on the point at which their
// paths to the root (COM) join.

val (youPath, sanPath) = listOf("YOU", "SAN").map { start ->
    val path = ArrayList<String>()

    var suborbiter = start
    while (orbits.containsKey(suborbiter)) {
        suborbiter = orbits.getValue(suborbiter)
        path.add(suborbiter)
    }

    path
}

val intersection = youPath.intersect(sanPath)

println("Part 2: ${youPath.size + sanPath.size - (2 * intersection.size)}")
