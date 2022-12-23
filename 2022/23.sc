#!/usr/bin/env amm
import scala.io.Source

val initialElves = Source.fromFile("23.txt").getLines.zipWithIndex.flatMap { case (line, y) =>
    line.toCharArray.zipWithIndex.filter(_._1 == '#').map { case (char, x) => (x, y) }
}.toSet

val allDirs = (for (y <- -1 to 1; x <- -1 to 1) yield (pos: (Int, Int)) => (pos._1 + x, pos._2 + y)).patch(4, Nil, 1)
val Seq(nw, n, ne, w, e, sw, s, se) = allDirs
val dirGroups = Seq(
    (Seq(n, ne, nw), (pos: (Int, Int)) => (pos._1, pos._2 - 1)),
    (Seq(s, se, sw), (pos: (Int, Int)) => (pos._1, pos._2 + 1)),
    (Seq(w, nw, sw), (pos: (Int, Int)) => (pos._1 - 1, pos._2)),
    (Seq(e, ne, se), (pos: (Int, Int)) => (pos._1 + 1, pos._2)),
)

def noElvesAt(dirs: Seq[((Int, Int)) => (Int, Int)], elf: (Int, Int), elves: Set[(Int, Int)]): Boolean = {
    dirs.forall(dir => !elves.contains(dir(elf)))
}

def proposedMove(elf: (Int, Int), initialDir: Int, elves: Set[(Int, Int)]): Option[((Int, Int))] = {
    if (noElvesAt(allDirs, elf, elves)) return None

    for (dir <- initialDir until initialDir + 4) {
        val dirGroup = dirGroups(dir % dirGroups.length)
        if (noElvesAt(dirGroup._1, elf, elves)) return Some(dirGroup._2(elf))
    }

    None
}

def simulateRound(elves: Set[(Int, Int)], initialDir: Int): (Set[(Int, Int)], Int) = {
    val proposedMoves = elves
        .map { elf => elf -> proposedMove(elf, initialDir, elves) }
        .toMap
        .collect { case (elf, Some(move)) => elf -> move }
    val moveCounts = proposedMoves.values.groupBy(identity).mapValues(_.size)

    var successfulMoves = 0
    val newElves = elves.map { elf =>
        if (proposedMoves.contains(elf)) {
            val newPos = proposedMoves(elf)
            if (moveCounts(newPos) == 1) {
                successfulMoves += 1
                newPos
            } else {
                elf
            }
        } else {
            elf
        }
    }

    (newElves, successfulMoves)
}

def rectangleMinMaxes(elves: Set[(Int, Int)]): ((Int, Int), (Int, Int)) = {
    elves.foldLeft(((Int.MaxValue, Int.MinValue), (Int.MaxValue, Int.MinValue))) {
        case (((minX, maxX), (minY, maxY)), elf) => {
            ((minX min elf._1, maxX max elf._1), (minY min elf._2, maxY max elf._2))
        }
    }
}

def printElves(elves: Set[(Int, Int)]): Unit = {
    val ((minX, maxX), (minY, maxY)) = rectangleMinMaxes(elves)
    println(s"x in [${minX}, ${maxX}], y in [${minY}, ${maxY}]")
    for (y <- minY to maxY) {
        for (x <- minX to maxX) {
            print(if (elves.contains((x, y))) '#' else '.')
        }
        println
    }
    println
}

val part1Rounds = 10
val part1Elves = (0 until part1Rounds).foldLeft(initialElves)((elves, initialDir) => simulateRound(elves, initialDir)._1)

{
    val ((minX, maxX), (minY, maxY)) = rectangleMinMaxes(part1Elves)
    printElves(part1Elves)
    println(s"Part 1: ${(maxX - minX + 1) * (maxY - minY + 1) - part1Elves.size}")
}

def finalRound(elves: Set[(Int, Int)], fromRound: Int): Int = {
    var result = (elves, 1)
    var startTime = System.nanoTime
    var printThreshold = fromRound

    LazyList.from(fromRound).foreach { initialDir =>
        if (initialDir == printThreshold) {
            println(s"Reached beginning of round ${initialDir} after ${(System.nanoTime - startTime) / 1e9} seconds")
            printThreshold *= 2
        }

        result = simulateRound(result._1, initialDir)
        if (result._2 <= 0) {
            return initialDir + 1
        }
    }
    -1
}

println
println(s"Part 2: ${finalRound(part1Elves, part1Rounds)}")
