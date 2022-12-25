#!/usr/bin/env amm
import scala.collection.mutable.Queue
import scala.collection.mutable.Set
import scala.io.Source

// Discard the edges to keep it simple and assume we always go from top-left to bottom-right
val zoomedMap = Source.fromFile("24.txt")
    .mkString
    .replaceFirst(".+", "")
    .replaceFirst(".+$", "")
    .replaceAll("(?m)^#|#$", "")
    .trim
    .split("\n")
    .map(_.toCharArray)
    .toArray

val width = zoomedMap.head.length
val height = zoomedMap.length

val Seq(upBliz, downBliz) = Seq('^', 'v').map { direction =>
    (0 until width).map { x =>
        (0 until height).flatMap { y =>
            if (direction == zoomedMap(y)(x)) Some(y) else None
        }.toSet
    }
}

val Seq(leftBliz, rightBliz) = Seq('<', '>').map { direction =>
    zoomedMap.map { row =>
        row.zipWithIndex.flatMap { case (char, x) =>
            if (direction == char) Some(x) else None
        }.toSet
    }
}

val moveChoices = Seq[(Int, Int) => (Int, Int)](
    (x, y) => (x + 1, y),
    (x, y) => (x, y + 1),
    (x, y) => (x - 1, y),
    (x, y) => (x, y - 1),
    (x, y) => (x, y),
)

def gcd(a: Int, b: Int): Int = {
    return if (a == 0) b else gcd(b % a, a)
}

def positiveMod(dividend: Int, divisor: Int): Int = {
    val initialRemainder = dividend % divisor
    return if (initialRemainder < 0) initialRemainder + divisor else initialRemainder
}

def shortestPath(start: (Int, Int), finish: (Int, Int), initialOffset: Int = 0): Seq[(Int, Int)] = {
    val period = width * height / gcd(width max height, width min height)
    val queue = Queue(Seq(start))
    val visited = Set[((Int, Int), Int)]()

    LazyList.from(initialOffset + 1).foreach { nextSteps =>
        if (queue.size <= 0) {
            println("No solution!? This shouldn't happen.")
            return Seq()
        }

        for (_ <- queue.size to 1 by -1) {
            val path = queue.dequeue
            val pos = path.last
            val (x, y) = pos

            moveChoices.map { posGen => posGen(x, y) }.foreach { case (nextX, nextY) =>
                val cyclePosition = ((nextX, nextY), nextSteps % period)

                try {
                    if (
                        !leftBliz(nextY).contains((nextX + nextSteps) % width) &&
                        !rightBliz(nextY).contains(positiveMod(nextX - nextSteps, width)) &&
                        !upBliz(nextX).contains((nextY + nextSteps) % height) &&
                        !downBliz(nextX).contains(positiveMod(nextY - nextSteps, height)) &&
                        !visited.contains(cyclePosition)
                    ) {
                        if ((nextX, nextY) == finish) return path.drop(1) :+ finish
                        queue.addOne(path :+ (nextX, nextY))
                        visited.addOne(cyclePosition)
                    }
                } catch {
                    case _: IndexOutOfBoundsException => { }
                }
            }

            if (pos == start && nextSteps - initialOffset <= period) {
                queue.addOne(path :+ start)
            }
        }
    }

    Seq()
}

def updatedDisplayChar(display: Char, blizzard: Char): Char = {
    display match {
        case '.' => blizzard
        case '^' | 'v' | '<' | '>' => '2'
        case '2' => '3'
        case '3' => '4'
        case 'E' => throw new RuntimeException("You ran into a blizzard")
    }
}

def printPath(path: Seq[(Int, Int)]): Unit = {
    println(s"Path: ${path}")
    path.zipWithIndex.foreach { case (pos, steps) =>
        print('#')
        print(if (pos._2 < 0) 'E' else '.')
        println("#" * width)

        for (y <- 0 until height) {
            print('#')
            for (x <- 0 until width) {
                var display = '.'
                if ((x, y) == pos) {
                    display = 'E'
                }

                if (leftBliz(y).contains((x + steps) % width)) display = updatedDisplayChar(display, '<')
                if (rightBliz(y).contains(positiveMod(x - steps, width))) display = updatedDisplayChar(display, '>')
                if (upBliz(x).contains((y + steps) % height)) display = updatedDisplayChar(display, '^')
                if (downBliz(x).contains(positiveMod(y - steps, height))) display = updatedDisplayChar(display, 'v')
                print(display)
            }
            println('#')
        }

        print("#" * width)
        print(if (pos._2 >= height) 'E' else '.')
        println('#')
        println
    }
}

val snacks = (0, -1)
val site = (width - 1, height)

val pathToSite = shortestPath(snacks, (site._1, site._2 - 1)) :+ site
println(s"Part 1: ${pathToSite.size}")

val pathToSnacks = shortestPath(site, (snacks._1, snacks._2 + 1), pathToSite.size) :+ snacks
val pathToSite2 = shortestPath(snacks, (site._1, site._2 - 1), pathToSite.size + pathToSnacks.size) :+ site
println(s"Part 2: ${pathToSite.size + pathToSnacks.size + pathToSite2.size}")
