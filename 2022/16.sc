#!/usr/bin/env amm
import scala.collection.mutable.Map
import scala.collection.mutable.Queue
import scala.collection.immutable.Set
import scala.io.Source

val flowRates = Map[String, Int]() // Don't put zeroes in here
val paths = Map[String, Seq[String]]()
Source.fromFile("16.txt").getLines.foreach { line =>
    val mi = "^Valve ([A-Z]+) has flow rate=(\\d+); tunnels? leads? to valves? ([A-Z, ]+)$".r.findFirstMatchIn(line).get

    val src = mi.group(1)

    val flowRate = mi.group(2).toInt
    if (flowRate > 0) {
        flowRates.put(src, flowRate)
    }

    paths.put(src, "[, ]+".r.split(mi.group(3)))
}

val distances = Map[String, Map[String, Int]]()

(Seq("AA") ++ flowRates.keys).foreach { src =>
    val queue = Queue(src)
    val visited = collection.mutable.Set(src)
    val srcDistances = Map[String, Int]()

    var distance = 1
    while (!queue.isEmpty) {
        for (_ <- queue.size to 1 by -1) {
            val node = queue.dequeue
            paths.get(node).get.foreach { neighbour =>
                if (!visited.contains(neighbour)) {
                    visited.addOne(neighbour)
                    queue.addOne(neighbour)
                    if (flowRates.contains(neighbour)) {
                        srcDistances.put(neighbour, distance)
                    }
                }
            }
        }
        distance += 1
    }

    distances.put(src, srcDistances)
}

def optimalSolo(
    currentValve: String,
    timeLeft: Int,
    totalReleased: Int,
    distances: Map[String, Map[String, Int]],
    visited: Set[String] = Set[String]()
): Int = {
    val currentValveDist = distances.get(currentValve).get
    val nextValves = currentValveDist.keys.filter { nextValve =>
        !visited.contains(nextValve) && currentValveDist.get(nextValve).get < timeLeft
    }
    totalReleased + nextValves.foldLeft(0)((acc, nextValve) => {
        val newTimeLeft = timeLeft - currentValveDist.get(nextValve).get - 1
        acc max optimalSolo(
            nextValve,
            newTimeLeft,
            flowRates(nextValve) * newTimeLeft,
            distances,
            visited ++ Set(nextValve)
        )
    })
}

println(s"Part 1: ${optimalSolo("AA", 30, 0, distances)}")

def optimalDuo(
    creatures: Array[(String, Int)], // (nextDestination, cooldown)
    timeLeft: Int,
    totalReleased: Int,
    distances: Map[String, Map[String, Int]],
    visited: Set[String] = Set[String]()
): Int = {
    // @TODO: Make this not take hours
    val creatureIndex = creatures.zipWithIndex.minBy(_._1._2)._2
    val currentCreature = creatures(creatureIndex)

    val otherCreature = creatures(1 - creatureIndex)
    val newOtherCreature = (otherCreature._1, otherCreature._2 - currentCreature._2)

    val currentValve = currentCreature._1
    val currentValveDist = distances.get(currentValve).get

    val newTimeLeft = timeLeft - currentCreature._2
    val nextValves = currentValveDist.keys.filter { nextValve =>
        !visited.contains(nextValve) && currentValveDist.get(nextValve).get < newTimeLeft
    }

    totalReleased + nextValves.foldLeft(0)((acc, nextValve) => {
        val timeRequired = currentValveDist.get(nextValve).get + 1
        val newTotal = flowRates(nextValve) * (newTimeLeft - timeRequired)

        var result = acc max optimalDuo(
            Array((nextValve, timeRequired), newOtherCreature),
            newTimeLeft,
            newTotal,
            distances,
            visited ++ Set(nextValve)
        )
        if (nextValves.size <= 3) { // Arbitrary threshold until this is optimized
            result = acc max optimalSolo(
                nextValve,
                newTimeLeft - timeRequired,
                newTotal,
                distances,
                visited ++ Set(nextValve)
            )
        }
        result
    })
}

println(s"Part 2: ${optimalDuo(Array(("AA", 0), ("AA", 0)), 26, 0, distances)}")
