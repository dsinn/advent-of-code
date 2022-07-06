#!/usr/bin/env kotlin

import java.io.File

val (min, max) = File("04.txt").readText().trim().split('-').map { it.toInt() }

val regexes = listOf(
    """.*?(\d)\1.*""",
    "1*2*3*4*5*6*7*8*9*",
).map { it.toRegex() }

var part1 = 0
var part2 = 0
(min..max).forEach {
    it.toString().let { password ->
        if (regexes.all { regex -> regex.matches(password) }) {
            part1++
            if (password.split("""(.)(?!\1)""".toRegex()).any { it.length == 1 }) {
                part2++
            }
        }
    }
}

println("Part 1: ${part1}")
println("Part 2: ${part2}")
