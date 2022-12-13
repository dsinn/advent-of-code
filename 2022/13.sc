#!/usr/bin/env amm
import scala.io.Source
import $ivy.`io.spray::spray-json:1.3.6`, spray.json._, DefaultJsonProtocol._

def compare(left: JsValue, right: JsValue): Int = {
    (left, right) match {
        case (_: JsArray, _: JsArray) => {
            val Seq(leftArray, rightArray) = Seq(left, right).map(_.convertTo[Array[JsValue]])

            leftArray.zipWithIndex.foreach { case (leftElem, i) =>
                if (!rightArray.isDefinedAt(i)) {
                    return -1
                }

                val result = compare(leftElem, rightArray(i))
                if (result != 0) {
                    return result
                }
            }

            if (leftArray.size == rightArray.size) 0 else 1
        }
        case (_: JsArray, _: JsNumber) => {
            compare(left, JsArray(Vector(right)))
        }
        case (_: JsNumber, _: JsArray) =>
            compare(JsArray(Vector(left)), right)
        case (_: JsNumber, _: JsNumber) => (right.convertTo[Int] - left.convertTo[Int]).signum
        case _ => throw new RuntimeException(
            s"Invalid types when comparing ${left} and ${right}; only ints and arrays of ints are allowed."
        )
    }
}

print("Part 1: ")
println(
    Source.fromFile("13.txt").mkString.split("\n\n").zip(LazyList.from(1)).map { case (pair, i) =>
        val Array(left, right) = pair.split("\n").map(_.parseJson)
        if (compare(left, right) > 0) i else 0
    }.reduce(_ + _)
)

val dividers = Array(2, 6).map { number => JsArray(Vector(JsArray(Vector(JsNumber(number))))) }
val orderedPackets = (Source.fromFile("13.txt").mkString.split("\n").filter(_.length > 0).map(_.parseJson) ++ dividers)
    .sortWith { (a, b) => compare(a, b) > 0 }

print("Part 2: ")
println(dividers.map { divider => orderedPackets.indexOf(divider) + 1 }.reduce(_ * _))
