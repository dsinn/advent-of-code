#!/usr/bin/env kotlin

import java.io.File

fun execute(originalCodes: ArrayList<Int>): Int {
    val intcodes = ArrayList<Int>(originalCodes)

    var pointer = 0
    loop@while (true) {
        when (intcodes[pointer]) {
            1 -> { intcodes[intcodes[pointer + 3]] = intcodes[intcodes[pointer + 1]] + intcodes[intcodes[pointer + 2]] }
            2 -> { intcodes[intcodes[pointer + 3]] = intcodes[intcodes[pointer + 1]] * intcodes[intcodes[pointer + 2]] }
            99 -> { break@loop }
        }
        pointer += 4
    }

    return intcodes[0]
}

val intcodes: ArrayList<Int> = ArrayList<Int>(File("02.txt").readText().trim().split(",").map { it.toInt() })

intcodes[1] = 12
intcodes[2] = 2
println("Part 1: ${execute(intcodes)}")

part2@for (noun in 0..99) {
    for (verb in 0..99) {
        intcodes[1] = noun
        intcodes[2] = verb
        if (execute(intcodes) == 19690720) {
            println("Part 2: ${noun * 100 + verb}")
            break@part2
        }
    }
}
