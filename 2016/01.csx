#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Numerics;
using System.Text.RegularExpressions;

(int, int) direction = (0, 1); // North
(int, int) position = (0, 0);

HashSet<(int, int)> visited = new HashSet<(int, int)>();
visited.Add(position);
int part2 = -1;

foreach (string instruction in Helper.GetAllInputText().Split(", ")) {
    direction = instruction[0] switch {
        'L' => (-direction.Item2, direction.Item1),
        'R' => (direction.Item2, -direction.Item1),
        _ => throw new ArgumentException($"Unable to understand the direction in \"{instruction}\"."),
    };
    int magnitude = Int32.Parse(instruction.Substring(1));

    if (part2 < 0) {
        for (int i = 1; i <= magnitude; i++) {
            (int, int) interimPosition = (position.Item1 + direction.Item1 * i, position.Item2 + direction.Item2 * i);
            if (visited.Contains(interimPosition)) {
                part2 = Math.Abs(interimPosition.Item1) + Math.Abs(interimPosition.Item2);
            } else {
                visited.Add(interimPosition);
            }
        }
    }

    position.Item1 += direction.Item1 * magnitude;
    position.Item2 += direction.Item2 * magnitude;
}

Console.WriteLine($"Part 1: {Math.Abs(position.Item1) + Math.Abs(position.Item2)}");
Console.WriteLine($"Part 2: {part2}");
