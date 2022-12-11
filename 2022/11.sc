#!/usr/bin/env amm
import scala.collection.mutable.ArrayBuffer
import scala.io.Source

class Monkey(
    val items: ArrayBuffer[Item],
    operation: Long => Long,
    val divisor: Int,
    trueMonkeyIndex: Int,
    falseMonkeyIndex: Int,
) {
    var inspections = 0

    def throwItems(postInspectionAdjustment: Long => Long): ArrayBuffer[(Int, Item)] = {
        val result = items.map { item =>
            item.worryLevel = postInspectionAdjustment(operation(item.worryLevel))
            (
                if (item.worryLevel % divisor == 0) trueMonkeyIndex else falseMonkeyIndex,
                item
            )
        }

        inspections += items.size
        items.clear
        result
    }
}

class Item(var worryLevel: Long) { }

def parseLastWordAsInt(s: String): Int = {
    s.split(" ").last.toInt
}

List(20, 10000)
    .zip(LazyList.from(1))
    .zip(
        List(
            (_: Array[Monkey]) => (x: Long) => x / 3,
            (monkeys: Array[Monkey]) => (x: Long) => x % monkeys.foldLeft(1)((product, monkey) => product * monkey.divisor)
        )
    )
    .foreach {
        case ((rounds, part), postInspectionAdjustmentGenerator) => {
            // Assume the monkey indices are in asceding order so I don't have to deal with it
            val monkeys = Source.fromFile("11.txt").mkString.split("\n\n").map { monkeyDefString =>
                val paramStrings = monkeyDefString.split("\n").map(":|(?=[+*])".r.split(_).last.trim)

                val itemCopies = paramStrings(1)
                    .split(", ")
                    .map(worryLevelString => new Item(worryLevelString.toLong))
                    .to(ArrayBuffer)

                val operationOperator = (paramStrings(2).head match {
                    case '+' => (_: Long) + (_: Long)
                    case '*' => (_: Long) * (_: Long)
                })

                new Monkey(
                    itemCopies,
                    old => operationOperator(
                        old,
                        if (paramStrings(2).endsWith("old")) old else parseLastWordAsInt(paramStrings(2))
                    ),
                    parseLastWordAsInt(paramStrings(3)),
                    parseLastWordAsInt(paramStrings(4)),
                    parseLastWordAsInt(paramStrings(5))
                )
            }

            val postInspectionAdjustment = postInspectionAdjustmentGenerator(monkeys)

            for (round <- 1 to rounds) {
                monkeys.foreach { monkey =>
                    monkey.throwItems(postInspectionAdjustment).foreach { case (destination, item) =>
                        monkeys(destination).items.addOne(item)
                    }
                }
            }

            println(s"Part ${part}: ${monkeys.map(_.inspections.toLong).sortBy(-_).take(2).reduce(_ * _)}")
        }
    }
