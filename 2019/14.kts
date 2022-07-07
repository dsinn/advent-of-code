#!/usr/bin/env kotlin

import java.io.File
import kotlin.math.ceil

data class Quantity(val n: Int, val chemical: String)
data class Reaction(val input: List<Quantity>, val output: Int)

// Assume there is only one way to create each chemical
val recipes = File("14.txt")
    .readLines()
    .map { line -> """(.*?) => (\d+) ([A-Z]+)""".toRegex().matchEntire(line) }
    .associate { match ->
        match!!.groupValues[3] to Reaction(
            match.groupValues[1].split(", ").map { quantityString ->
                """(\d+) ([A-Z]+)""".toRegex().matchEntire(quantityString)!!.groupValues.let {
                    Quantity(it[1].toInt(), it[2])
                }
            },
            match.groupValues[2].toInt()
        )
    }

fun computeOreCost(q: Quantity, recipes: Map<String, Reaction>, leftovers: MutableMap<String, Int>): Int {
    if (q.chemical == "ORE") return q.n

    val recipe = recipes.getValue(q.chemical)
    var reactionsNeeded = ceil(q.n.toFloat() / recipe.output.toFloat()).toInt()

    val leftoverOutput = reactionsNeeded * recipe.output - q.n
    leftovers[q.chemical] = leftovers.getOrPut(q.chemical) { 0 } + leftoverOutput

    val reactionsSavedFromLeftovers = leftovers.getValue(q.chemical) / recipe.output
    leftovers[q.chemical] = leftovers.getValue(q.chemical) % recipe.output
    reactionsNeeded -= reactionsSavedFromLeftovers

    return recipe.input.map { computeOreCost(Quantity(it.n * reactionsNeeded, it.chemical), recipes, leftovers) }.sum()
}

val leftovers:  MutableMap<String, Int> = mutableMapOf()
var oreUsed = computeOreCost(Quantity(1, "FUEL"), recipes, leftovers).toLong()

println("Part 1: $oreUsed")

val ORE_LIMIT = 1000000000000L

var fuelProduced = 1
while (oreUsed <= ORE_LIMIT) {
    oreUsed += computeOreCost(Quantity(1, "FUEL"), recipes, leftovers).toLong()
    fuelProduced++

    if (leftovers.values.all { it == 0 }) {
        // Shortcut if the period is small.
        // ...it was not for my input and I waited FIVE minutes. ;_;
        // @TODO Make part 2 faster.
        println("Cycle found at fuelProduced = $fuelProduced, oreUsed = $oreUsed")

        val cycles = ORE_LIMIT / oreUsed
        oreUsed *= cycles
        fuelProduced *= cycles.toInt()

        println("Jumping to fuelProduced = $fuelProduced, oreUsed = $oreUsed after $cycles cycles")
    }
}

println("Part 2: ${fuelProduced - 1}")
