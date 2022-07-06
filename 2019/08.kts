#!/usr/bin/env kotlin

import java.io.File

val HEIGHT = 6
val WIDTH = 25

val rawLayerData = File("08.txt").readText().trim().chunked(HEIGHT * WIDTH)

rawLayerData
    .indices
    .minBy { i -> rawLayerData[i].count { char -> char == '0' } }
    .let { i -> rawLayerData[i] }
    .let { rawData -> rawData.count { char -> char == '1' } * rawData.count { char -> char == '2' } }
    .let { println("Part 1: ${it}") }

println("\nPart 2:")
val outputMap = mapOf('0' to '█', '1' to ' ')
val layers = rawLayerData.map { it.chunked(WIDTH) }
for (i in 0 until HEIGHT) {
    for (j in 0 until WIDTH) {
        print(layers.find { it[i][j] != '2' }!![i][j].let { char -> outputMap.getValue(char) })
    }
    println()
}
