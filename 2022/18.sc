#!/usr/bin/env amm
import scala.collection.mutable.Queue
import scala.io.Source

val lavaVoxels = Source.fromFile("18.txt").getLines
    // + 1 because there are zeroes but no negative numbers.
    // This is for part 2's external space array because even though it consumes slightly more memory,
    // it's more convenient when the entire perimeter of the array is water/steam so that
    // the BFS can be done from a single starting point.
    .map {line => line.split(",").map(_.toInt + 1) }
    .map { array => (array(0), array(1), array(2)) }
    .toSet

val adjacencyGens = Seq(
    (pos: (Int, Int, Int)) => ((pos._1 - 1), pos._2, pos._3),
    (pos: (Int, Int, Int)) => ((pos._1 + 1), pos._2, pos._3),
    (pos: (Int, Int, Int)) => ((pos._1), pos._2 - 1, pos._3),
    (pos: (Int, Int, Int)) => ((pos._1), pos._2 + 1, pos._3),
    (pos: (Int, Int, Int)) => ((pos._1), pos._2, pos._3 - 1),
    (pos: (Int, Int, Int)) => ((pos._1), pos._2, pos._3 + 1),
)

print("Part 1: ")
println(
    lavaVoxels.foldLeft(0)(
        (total, pos) => total + adjacencyGens.count { adjacencyGen => !lavaVoxels.contains(adjacencyGen(pos)) }
    )
)

// Similar to the comment above, + 2 so that the last index is guaranteed empty space (+ 1 be the edge of the lava).
val external = Array.ofDim[Boolean](
    lavaVoxels.map(_._1).max + 2,
    lavaVoxels.map(_._2).max + 2,
    lavaVoxels.map(_._3).max + 2
)

{
    val queue = Queue((0, 0, 0))
    while (!queue.isEmpty) {
        val pos = queue.dequeue
        adjacencyGens.map { _(pos) }.foreach { pos =>
            try {
                if (!lavaVoxels.contains(pos) && !external(pos._1)(pos._2)(pos._3)) {
                    external(pos._1)(pos._2)(pos._3) = true
                    queue.addOne(pos)
                }
            } catch {
                case _: ArrayIndexOutOfBoundsException => { }
            }
        }
    }
}

print("Part 2: ")
println(
    lavaVoxels.foldLeft(0)((total, pos) => total + adjacencyGens.count { adjacencyGen =>
        val neighbour = adjacencyGen(pos)
        try {
            external(neighbour._1)(neighbour._2)(neighbour._3)
        } catch {
            case _: ArrayIndexOutOfBoundsException => true
        }
    })
)
