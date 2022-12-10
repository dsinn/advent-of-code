#!/usr/bin/env amm
import scala.io.Source

val heights = Source.fromFile("08.txt").getLines.toArray.map(_.split("").map(_.toInt))

{
    val isVisible = Array.ofDim[Boolean](heights.length, heights.head.length)

    def markVisibleTreesInOneDirection(range: Range, heightAtIndex: Int => Int, markVisible: Int => Unit): Unit = {
        var tallestHeight = -1
        range.foreach { k =>
            val currentHeight = heightAtIndex(k)
            if (currentHeight > tallestHeight) markVisible(k)
            tallestHeight = tallestHeight max currentHeight
        }
    }

    val axes = Array(0 until isVisible.length, 0 until isVisible.head.length)

    for (
        (axisIndex, heightFunc, visibleFunc) <- (
            Array(0, 1),
            List(
                (i: Int) => heights(i)(_: Int),
                (j: Int) => heights(_: Int)(j)
            ),
            List(
                (i: Int) => isVisible(i)(_: Int) = true,
                (j: Int) => isVisible(_: Int)(j) = true
            )
        ).zipped;
        i <- axes(axisIndex)
    ) {
        val otherAxis = axes(1 - axisIndex)
        List(otherAxis, otherAxis.reverse).foreach { range =>
            markVisibleTreesInOneDirection(range, heightFunc(i), visibleFunc(i))
        }
    }

    val edgeTreeCount = 2 * (isVisible.length + isVisible.head.length) - 4 // Perimeter formula
    print("Part 1: ")
    println(
        (1 to isVisible.length - 2).foldLeft(edgeTreeCount)(
            (total, i) => total + (1 to isVisible(i).length - 2).count(isVisible(i)(_))
        )
    )
}

{
    val scores = Array.fill(heights.length) {
        Array.fill(heights.head.length) { 1 }
    }

    def calcScoreInOneDirection(height: Int, range: Range, heightAtIndex: Int => Int): Int = {
        var treeCount = 0
        range.foreach { k =>
            treeCount += 1
            if (heightAtIndex(k) >= height) {
                return treeCount
            }
        }
        treeCount
    }

    for (
        i <- 0 until scores.length;
        j <- 0 until scores.head.length;
        (ranges, heightAtIndex) <- List(
            List(i - 1 to 0 by -1, i + 1 until scores.length),
            List(j - 1 to 0 by -1, j + 1 until scores.head.length)
        ).zip(
            List(
                heights(_: Int)(j),
                heights(i)(_: Int)
            )
        );
        range <- ranges
    ) {
        scores(i)(j) *= calcScoreInOneDirection(heights(i)(j), range, heightAtIndex)
    }

    println(s"Part 2: ${scores.foldLeft(0)((answer, row) => answer max row.max)}")
}
