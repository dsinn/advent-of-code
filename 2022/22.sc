#!/usr/bin/env amm
import scala.io.Source

val Array(mapString, pathString) = Source.fromFile("22.txt").mkString.replaceFirst("\\s+$", "").split("\n\n")
val lines = mapString.split("\n")

val xMax = lines.maxBy(_.length).length
val yMax = lines.length

val charMap = lines.map(line => line.padTo(xMax, ' ').toArray)

// Now you're thinking with
val leftPortals = charMap.zipWithIndex.map { case (row, y) =>
    val left = row.indexWhere(_ != ' ') - 1
    val right = row.lastIndexWhere(_ != ' ')
    (y, left) -> ((y, right), (x: Int) => x)
}.toMap
val rightPortals = for ((k, v) <- leftPortals) yield ((v._1._1, v._1._2 + 1), ((k._1, k._2 + 1), v._2))

val topPortals = (0 until xMax).map { x =>
    val top = LazyList.from(0).find(y => charMap(y)(x) != ' ').get - 1
    val bottom = LazyList.from(yMax - 1, -1).find(y => charMap(y)(x) != ' ').get
    (top, x) -> ((bottom, x), (x: Int) => x)
}.toMap
val bottomPortals = for ((k, v) <- topPortals) yield ((v._1._1 + 1, v._1._2), ((k._1 + 1, k._2), v._2))

val isOpen = Array.ofDim[Boolean](yMax, xMax)
for (x <- 0 until xMax; y <- 0 until yMax) {
    if (charMap(y)(x) == '.') {
        isOpen(y)(x) = true
    }
}

val facings: Array[((Int, Int)) => (Int, Int)] = Array(
    pos => (pos._1, pos._2 + 1),
    pos => (pos._1 + 1, pos._2),
    pos => (pos._1, pos._2 - 1),
    pos => (pos._1 - 1, pos._2),
)
val portals = Array(
    rightPortals,
    bottomPortals,
    leftPortals,
    topPortals,
)

val initialPos = (0, isOpen.head.indexWhere(bool => bool))
var pos = initialPos
var facingIndex = 0

def walkStraight(distance: Int): Unit = {
    for (i <- 1 to distance) {
        val facing = facings(facingIndex)
        val facingPortals = portals(facingIndex)

        var nextPos = facing(pos)
        var nextFacingIndex = facingIndex

        if (facingPortals.contains(nextPos)) {
            val portalData = facingPortals.get(nextPos).get
            nextPos = portalData._1
            nextFacingIndex = portalData._2.apply(facingIndex)
        }

        if (charMap(nextPos._1)(nextPos._2) == ' ') {
            println(
                """
                ERROR: You are out of bounds; this solution is hardcoded to a specific cube net, so if you got a
                different one, an isomorph, or are simply feeding in the example, this is guaranteed to fail.
                I don't know how to make a generalized solution. :(
                """.stripMargin.replaceAll("\n", "")
            )
            System.exit(1)
        }

        if (!isOpen(nextPos._1)(nextPos._2)) {
            return
        }
        pos = nextPos
        facingIndex = nextFacingIndex
    }
}

def walkPath(): Int = {
    "(?<=[LR])|(?=[LR])".r.split(pathString).foreach { token =>
        token match {
            case "L" => facingIndex = (facingIndex - 1 + facings.length) % facings.length
            case "R" => facingIndex = (facingIndex + 1) % facings.length
            case _ => walkStraight(token.toInt)
        }
    }
    println(s"Stopped at ${pos} while facing direction #${facingIndex}")
    1000 * (pos._1 + 1) + 4 * (pos._2 + 1) + facingIndex
}

println(s"Part 1: ${walkPath}")

// TODO: Generalize to any cube net, not just the one I got, which is
//  ##
//  #
//  #
// ##
// #

portals(0) =
    (0 until 50).map { y => (y, 150) -> ((149 - y, 99), (_: Int) => 2) }.toMap ++
    (50 until 100).map { y => (y, 100) -> ((49, y + 50), (_: Int) => 3) }.toMap ++
    (100 until 150).map { y => (y, 100) -> ((149 - y, 149), (_: Int) => 2) }.toMap ++
    (150 until 200).map { y => (y, 50) -> ((149, y - 100), (_: Int) => 3) }.toMap
portals(2) =
    (0 until 50).map { y => (y, 49) -> ((149 - y, 0), (_: Int) => 0) }.toMap ++
    (50 until 100).map { y => (y, 49) -> ((100, y - 50), (_: Int) => 1) }.toMap ++
    (100 until 150).map { y => (y, -1) -> ((149 - y, 50), (_: Int) => 0) }.toMap ++
    (150 until 200).map { y => (y, -1) -> ((0, y - 100), (_: Int) => 1) }.toMap
portals(1) =
    (0 until 50).map { x => (200, x) -> ((0, x + 100), (_: Int) => 1) }.toMap ++
    (50 until 100).map { x => (150, x) -> ((x + 100, 49), (_: Int) => 2) }.toMap ++
    (100 until 150).map { x => (50, x) -> ((x - 50, 99), (_: Int) => 2) }.toMap
portals(3) =
    (0 until 50).map { x => (99, x) -> ((x + 50, 50), (_: Int) => 0) }.toMap ++
    (50 until 100).map { x => (-1, x) -> ((x + 100, 0), (_: Int) => 0) }.toMap ++
    (100 until 150).map { x => (-1, x) -> ((199, x - 100), (_: Int) => 3) }.toMap

pos = initialPos
facingIndex = 0
println(s"Part 2: ${walkPath}")
