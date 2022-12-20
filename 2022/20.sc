#!/usr/bin/env amm
import scala.collection.mutable.ArrayDeque
import scala.io.Source

def mixArray(numbers: Array[Long], times: Int = 1): Array[Long] = {
    val firstMixIDs = collection.mutable.LinkedHashSet[Int]()
    val data = ArrayDeque.from(numbers.zipWithIndex)

    {
        var cursor = 0
        while (cursor < data.length) {
            val tuple = data(cursor)
            if (firstMixIDs.contains(tuple._2)) {
                cursor += 1
            } else {
                val destination = mixNumber(data, cursor, tuple)

                if (destination < cursor) {
                    cursor -= 1
                }
                firstMixIDs.addOne(tuple._2)
            }
        }
    }

    // This takes a few minutes, ugh.
    for (_ <- 2 to times) {
        firstMixIDs.foreach { id =>
            val index = data.indexWhere(id == _._2)
            mixNumber(data, index, data(index))
        }
    }

    data.map(_._1).toArray
}

def mixNumber(data: ArrayDeque[(Long, Int)], index: Int, tuple: (Long, Int)): Int = {
    data.remove(index)
    val remainder = ((index + tuple._1) % data.length).toInt
    val destination = remainder + (if (remainder < 0) data.length else 0)
    data.insert(destination, tuple)
    destination
}

def groveCoordinates(numbers: Array[Long]): Long = {
    val zeroIndex = numbers.indexOf(0)
    (zeroIndex + 1000 to zeroIndex + 3000 by 1000).map { i => numbers(i % numbers.size) }.reduce(_ + _)
}

val numbers = Source.fromFile("20.txt").getLines.map(_.toLong).toArray
println(s"Part 1: ${groveCoordinates(mixArray(numbers))}")
println(s"Part 2: ${groveCoordinates(mixArray(numbers.map(_ * 811589153), 10))}")
