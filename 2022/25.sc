#!/usr/bin/env amm
import scala.io.Source

def snafu2long(snafu: String): Long = {
    snafu.split("").reverse.zipWithIndex.foldLeft((0L, 1L)) { case ((sum, power), (charString, exponent)) =>
        (
            sum + (charString match {
                case "=" => -2L * power
                case "-" => -power
                case _ => charString.toLong * power
            }),
            power * 5
        )
    }._1
}

def long2snafu(long: Long): String = {
    if (long < 0) throw new IllegalArgumentException("Negative arguments are not implemented in long2snafu.")
    if (long == 0) return ""

    val quotient = long / 5L
    val remainder = long % 5L
    val (carry, digit) = remainder match {
        case 4L => (1L, "-")
        case 3L => (1L, "=")
        case _ => (0L, remainder.toString)
    }
    return long2snafu(quotient + carry) + digit
}

val sum = Source.fromFile("25.txt").getLines.map { line => snafu2long(line) }.reduce(_ + _)
println(s"(My Teen Romantic Comedy) SNAFU: ${long2snafu(sum)}")
