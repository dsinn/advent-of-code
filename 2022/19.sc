#!/usr/bin/env amm
import scala.collection.immutable.Set
import scala.io.Source

// TODO: Part 2 still takes minutes.
def optimalGeodes(
    costs: Map[String, Map[String, Int]],
    minutesLeft: Int,
    maxRobots: Map[String, Int],
    robots: Map[String, Int] = Map("ore" -> 1),
    inventory: Map[String, Int] = Map(),
    nextPurchase: String = ""
): Int = {
    if (minutesLeft <= 0) {
        return inventory.getOrElse("geode", 0)
    }

    if (nextPurchase == "") {
        return Seq("ore", "clay").map { robot =>
            optimalGeodes(costs, minutesLeft, maxRobots, robots, inventory, robot)
        }.max
    }

    val nextMinutesLeft = minutesLeft - 1

    val purchaseCost = costs(nextPurchase)
    if (purchaseCost.exists { case (resource, quantity) => inventory.getOrElse(resource, 0) < quantity }) {
        // Can't buy the robot we want yet; immediately go to the next minute
        val nextInv = addToInventory(inventory, robots)
        return optimalGeodes(costs, nextMinutesLeft, maxRobots, robots, nextInv, nextPurchase)
    }

    // Buy the robot we want
    val postPurchaseInv = addToInventory(
        inventory,
        purchaseCost.map { case (resource, quantity) => resource -> -quantity }.toMap
    )
    val nextRobots = robots.updated(nextPurchase, robots.getOrElse(nextPurchase, 0) + 1)
    val nextMaxRobots = maxRobots.filterNot { case (robot, maxQuantity) =>
        // We have so much inventory and/or production that we can't run out,
        // even if we always buy the robot that costs the most of this resource from now on.
        postPurchaseInv.getOrElse(robot, 0) >= minutesLeft * (maxQuantity - nextRobots.getOrElse(robot, 0))
    }

    val nextInv = addToInventory(postPurchaseInv, robots)

    (nextMaxRobots.keySet ++ Set("geode")).map { nextPurchase =>
        optimalGeodes(costs, nextMinutesLeft, nextMaxRobots, nextRobots, nextInv, nextPurchase)
    }.max
}

def addToInventory(inventory: Map[String, Int], addition: Map[String, Int]): Map[String, Int] = {
    addition.foldLeft(inventory)((inv, additionKv) => {
        val (resource, quantity) = additionKv
        inv.updated(resource, inv.getOrElse(resource, 0) + quantity)
    })
}

def calcMaxRobots(costs: Map[String, Map[String, Int]]): Map[String, Int] = {
    val flatValues = costs.removed("ore").values.map(identity).flatten // Ore robots can only cost ore
    flatValues.groupBy(_._1).values.map(_.maxBy(_._2)).toMap.updatedWith("ore")(_.map(_ - 1))
}

val blueprints = LazyList.from(1).zip(
    Source.fromFile("19.txt").getLines.map { line =>
        "Each ([a-z]+) robot costs ([^.]+)".r.findAllMatchIn(line).map { mi =>
            mi.group(1) -> mi.group(2).split(" and ").map { resLine =>
                val Array(quantity, resource) = resLine.split(" ")
                resource -> quantity.toInt
            }.toMap
        }.toMap
    }
)

def heatUpYourRoom(blueprints: Seq[(Int, Map[String, Map[String, Int]])], minutes: Int): Seq[(Int, Int)] = {
    val partStartTime = System.nanoTime
    blueprints.map { case (id, costs) =>
        val bpStartTime = System.nanoTime
        val result = (id, optimalGeodes(costs, minutes, calcMaxRobots(costs)))
        val bpEndTime = System.nanoTime
        println(
            f"Blueprint ${result._1}%2s done with ${result._2}%2s geodes " +
                f"after ${(bpEndTime - bpStartTime) / 1e9}%.2fs (total ${(bpEndTime - partStartTime) / 1e9}%.2fs)"
        )
        result
    }
}

{
    val qualityLevels = heatUpYourRoom(blueprints, 24).map { case (id, geodes) => id * geodes }
    println(s"Part 1: Probably over ${qualityLevels.sum} (when I optimized Part 2, I messed up Part 1 somehow)")
}

println

{
    val geodes = heatUpYourRoom(blueprints.take(3), 32).map(_._2)
    println(s"Part 2: ${geodes.reduce(_ * _)}")
}
