#!/usr/bin/env amm
import scala.io.Source

val rocks = Array(
    // Have the highest position last (this is assumed later for optimization purposes)
    List((0, 0L), (1, 0L), (2, 0L), (3, 0L)), // Minus
    List((1, 0L), (0, 1L), (1, 1L), (2, 1L), (1, 2L)), // Plus
    List((0, 0L), (1, 0L), (2, 0L), (2, 1L), (2, 2L)), // Backwards L
    List((0, 0L), (0, 1L), (0, 2L), (0, 3L)), // Pipe
    List((0, 0L), (0, 1L), (1, 0L), (1, 1L)), // Square
)
var rockCount = 0L
var rockIndex = 0

val jet = Source.fromFile("17.txt").mkString.trim.toArray.map { c => if (c == '>') 1 else -1 }
var jetIndex = 0
val horizontalBounds = Map(-1 -> -1, 1 -> 7)

var occupied = collection.mutable.LinkedHashSet[(Int, Long)]()
var height = 0L

def dropRock(): Unit = {
    val rock = rocks(rockIndex)
    rockIndex = (rockIndex + 1) % rocks.length
    rockCount += 1
    var rockCorner = (2, height + 4)

    while (true) {
        val jetDirection = jet(jetIndex)
        jetIndex = (jetIndex + 1) % jet.length

        val horizontalBound = horizontalBounds.get(jetDirection).get
        if (rock.map { pos => (pos._1 + rockCorner._1 + jetDirection, pos._2 + rockCorner._2) }.forall {
            pos => !occupied.contains(pos) && pos._1 != horizontalBound
        }) {
            rockCorner = (rockCorner._1 + jetDirection, rockCorner._2)
        }

        val fakeFloor = 0L.max(height - 69L) // In case the `occupied` set cleanup is overaggressive, move the floor

        if (rock.map { pos => (pos._1 + rockCorner._1, pos._2 + rockCorner._2 - 1) }.exists { pos => occupied.contains(pos) || pos._2 <= fakeFloor }) {
            val rockPositions = rock.map { pos => (pos._1 + rockCorner._1, pos._2 + rockCorner._2) }
            occupied ++= rockPositions
            height = height max rockPositions.last._2 // Assume last position is highest
            occupied = occupied.drop(occupied.size - 100) // Arbitrarily sized cleanup
            return
        }
        rockCorner = (rockCorner._1, rockCorner._2 - 1)
    }
    List()
}

for (_ <- 0 until 2022) {
    dropRock
}
println(s"Part 1: ${height}")

def part2(): Long = {
    val prevStates = collection.mutable.Map[(Int, Int, String), (Long, Long)]()

    while (rockCount < 1000000000000L) {
        dropRock

        val state = (rockIndex, jetIndex, occupied.map { pos => s"${pos._1}-${height - pos._2}" }.mkString("/"))
        if (prevStates.contains(state)) {
            val (prevRockCount, prevHeight) = prevStates(state)
            val period = rockCount - prevRockCount
            val rocksLeft = 1000000000000L - rockCount
            val cycles = rocksLeft / period
            val heightJump = cycles * (height - prevHeight)
            val newRockCount = rockCount + cycles * period

            println(s"Skipped from rock ${rockCount} to ${newRockCount} rocks and height ${prevHeight} to ${height + heightJump}")
            rockCount = newRockCount
            height += heightJump
            occupied = occupied.map { pos => (pos._1, pos._2 + heightJump) }
            prevStates.clear
        }
        prevStates.put(state, (rockCount, height))
    }
    height
}

println(s"Part 2: ${part2}")
