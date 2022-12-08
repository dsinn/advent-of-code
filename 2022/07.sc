#!/usr/bin/env amm
import scala.io.Source
import scala.util.control.Breaks.{break, breakable}

class Dir(val name: String, val parent: Dir = null) {
    val dirs = collection.mutable.Map[String, Dir]()
    var size = 0
    private val files = collection.mutable.Map[String, Int]()

    def addFile(name: String, size: Int): Unit = {
        if (files.contains(name)) return

        files.put(name, size)

        var ancestor = this
        while (ancestor != null) {
            ancestor.size += size
            ancestor = ancestor.parent
        }
    }

    def inOrderIterator: Iterator[Dir] = {
        for (result <- Iterator(this) ++ dirs.values.flatMap(_.inOrderIterator)) yield result
    }

    def touchDir(name: String): Dir = {
        return dirs.getOrElseUpdate(name, new Dir(name, this))
    }
}

object Dir {
    val FileRegex = "^(\\d+) (.+)$".r

    def buildFileStructureFromOutputFile(filePath: String): Dir = {
        val root = new Dir("/")
        var cwd = root

        val lineIterator = Source.fromFile(filePath).getLines
        var line = lineIterator.next

        while (lineIterator.hasNext) {
            if (line.startsWith("$ cd ")) {
                val destination = line.substring(5).trim

                cwd = if (destination == "/") {
                    root
                } else if (destination == "..") {
                    cwd.parent
                } else {
                    cwd.touchDir(destination)
                }

                line = lineIterator.next
            } else if (line == "$ ls") {
                breakable {
                    while (true) {
                        if (!lineIterator.hasNext) {
                            break
                        }

                        line = lineIterator.next

                        if (line.startsWith("$")) {
                            break
                        }

                        val matchOption = FileRegex.findFirstMatchIn(line)
                        if (!matchOption.isEmpty) {
                            val mi = matchOption.get
                            cwd.addFile(mi.group(2), mi.group(1).toInt)
                        }
                    }
                }
            } else {
                throw new RuntimeException(s"I don't know how to handle \"${line}\"")
            }
        }

        return root
    }
}

val root = Dir.buildFileStructureFromOutputFile("07.txt")

print("Part 1: ")
println(root.inOrderIterator.foldLeft(0)((acc, dir) => acc + (if (dir.size <= 100000) dir.size else 0)))

val spaceToFree = 30000000 - 70000000 + root.size
print("Part 2: ")
println(
    root.inOrderIterator.foldLeft(Int.MaxValue)(
        (acc, dir) => acc.min(if (dir.size >= spaceToFree) dir.size else Int.MaxValue)
    )
)
