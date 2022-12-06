#!/usr/bin/env amm
import scala.io.Source

val message = Source.fromFile("06.txt").mkString

List(4, 14).zip(1 to 2).foreach { case (markerLength, part) =>
    val regex = (
        "(.)" + List.tabulate(markerLength - 1){ i =>
            List.tabulate(i + 1){ j => s"(?!\\${j + 1})" }.mkString
        }.mkString("(.)") + "."
    ).r
    println(s"Part ${part}: ${regex.findFirstMatchIn(message).get.start + markerLength}")
}
