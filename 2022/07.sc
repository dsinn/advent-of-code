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

    def touchDir(name: String): Dir = {
        return dirs.getOrElseUpdate(name, new Dir(name, this))
    }
}

def buildFileStructureFromOutputFile(filePath: String): Dir = {
    val lineIterator = Source.fromFile(filePath).getLines
    val fileRegex = "^(\\d+) (.+)$".r

    val root = new Dir("/")
    var line = lineIterator.next
    var cwd = root

    while (lineIterator.hasNext) {
        if (line.startsWith("$ cd ")) {
            val destination = line.substring(5).trim

            if (destination == "/") {
                cwd = root
            } else if (destination == "..") {
                cwd = cwd.parent
            } else {
                cwd = cwd.touchDir(destination)
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

                    val matchOption = fileRegex.findFirstMatchIn(line)
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

def inOrderIterator(dir: Dir): Iterator[Dir] = {
    for (result <- Iterator(dir) ++ dir.dirs.values.flatMap(inOrderIterator(_))) yield result
}

val root = buildFileStructureFromOutputFile("07.txt")

print("Part 1: ")
println(inOrderIterator(root).foldLeft(0)((acc, dir) => acc + (if (dir.size <= 100000) dir.size else 0)))

val spaceToFree = 30000000 - 70000000 + root.size
print("Part 2: ")
println(
    inOrderIterator(root).foldLeft(Int.MaxValue)(
        (acc, dir) => acc.min(if (dir.size >= spaceToFree) dir.size else Int.MaxValue)
    )
)
