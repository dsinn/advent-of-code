#!/usr/bin/env amm
import scala.io.Source

def decimal(snafu: String): Long = {
    snafu.split("").reverse.zipWithIndex.foldLeft((0L, 1L)) { case ((sum, power), (charString, exponent)) =>
        (
            sum + (charString match {
                case "=" => -2 * power
                case "-" => -power
                case _ => charString.toLong * power
            }),
            power * 5
        )
    }._1
}

val sum = Source.fromFile("25.txt").getLines.map { line => decimal(line) }.reduce(_ + _)

// TODO: Implement decimal -> snafu instead of computing by hand
val snafuGuess = "2-=0-=-2=111=220=100"
val diff = sum - decimal(snafuGuess)

if (diff > 0) {
    println(s"Your guess is too low by ${diff}")
} else if (diff < 0) {
    println(s"Your guess is too high by ${diff.abs}.")
} else {
    println(s"Your guess is correct! Enter:\n\n${snafuGuess}")
}
