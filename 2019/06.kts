#!/usr/bin/env kotlin

import java.io.File

// orbiter -> orbitee
val orbits = File("06.txt").readLines().associate { line -> line.split(")").let { it[1] to it[0] } }

val orbitCounts: MutableMap<String, Int> = mutableMapOf()

orbits.forEach { (orbiter, orbitee) ->
    var suborbiter = orbiter
    while (orbits.containsKey(suborbiter)) {
        orbitCounts[orbitee] = orbitCounts.getOrPut(orbitee, { 0 }) + 1
        suborbiter = orbits.getValue(suborbiter)
    }
}

println("Part 1: ${orbitCounts.values.sum()}")

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
