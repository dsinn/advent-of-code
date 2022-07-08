#!/usr/bin/env kotlin

import java.io.File
import kotlin.math.abs

val rawSignal = File("16.txt").readText().trim()
val signal = rawSignal.chunked(1).map { it.toInt() }.toMutableList()

fun joinFirstNToString(list: List<Int>, n: Int): String {
    return list.take(n).map { it.toString() }.joinToString("")
}

fun part1FFT(signal: MutableList<Int>): List<Int> {
    repeat(100) {
        (0 until signal.size).forEach { pos ->
            val period = pos + 1
            var pointer = pos
            var value = 0
            try {
                while (true) {
                    repeat(period) { value += signal[pointer++] }
                    pointer += period
                    repeat(period) { value -= signal[pointer++] }
                    pointer += period
                }
            } catch (_: IndexOutOfBoundsException) {
            }
            signal[pos] = abs(value) % 10
        }
    }

    return signal
}

part1FFT(signal).let { println("Part 1: ${joinFirstNToString(it, 8)}") }

val messageOffset = rawSignal.substring(0, 7).toInt()
// The nth digit is only used in the calculation for the first n digits of the phase,
// so chop off the first $messageOffset digits
val leftoverDigits = rawSignal.length * 10000 - messageOffset
val splitIndex = messageOffset % rawSignal.length
val choppedRealSignal = (rawSignal.substring(splitIndex) + rawSignal.repeat((leftoverDigits - 1) / rawSignal.length))
    .chunked(1)
    .map { it.toInt() }.toMutableList()

fun part2FFT(signal: MutableList<Int>): List<Int> {
    repeat(100) {
        // For purposes of speed, we make the assumption that the message offset is greater than half of the real signal
        // length (which it was for my input), so each digit of the next phase is just the sum of the digit in the same
        // position and the digits to the right, modulo 10. This skips all the repeating pattern logic.
        var value = 0
        (signal.size - 1 downTo 0).forEach { pos ->
            value += signal[pos]
            signal[pos] = value % 10
        }
    }

    return signal
}

part2FFT(choppedRealSignal).let { println("Part 2: ${joinFirstNToString(it, 8)}") }
