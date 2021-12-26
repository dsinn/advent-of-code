#!/usr/bin/env dotnet-script
#load "Helper.csx"

readonly char[,] PART1_KEYPAD = new char[,] {{'1', '2', '3'}, {'4', '5', '6'}, {'7', '8', '9'}};
readonly char[,] PART2_KEYPAD = {
    {'-', '-', '1', '-', '-'},
    {'-', '2', '3', '4', '-'},
    {'5', '6', '7', '8', '9'},
    {'-', 'A', 'B', 'C', '-'},
    {'-', '-', 'D', '-', '-'},
};

string part1Code = "", part2Code = "";
foreach (string line in Helper.GetInputLineEnumerable()) {
    (int, int) part1Position = (1, 1), part2Position = (2, 2);
    foreach (char c in line.ToCharArray()) {
        part1Position = c switch {
            'U' => (Math.Max(0, part1Position.Item1 - 1), part1Position.Item2),
            'D' => (Math.Min(2, part1Position.Item1 + 1), part1Position.Item2),
            'L' => (part1Position.Item1, Math.Max(0, part1Position.Item2 - 1)),
            'R' => (part1Position.Item1, Math.Min(2, part1Position.Item2 + 1)),
            _ => throw new ArgumentException($"Unable to understand the direction \"{c}\"."),
        };
        part2Position = c switch {
            'U' => (Math.Max(Math.Abs(2 - part2Position.Item2), part2Position.Item1 - 1), part2Position.Item2),
            'D' => (Math.Min(4 - Math.Abs(2 - part2Position.Item2), part2Position.Item1 + 1), part2Position.Item2),
            'L' => (part2Position.Item1, Math.Max(Math.Abs(2 - part2Position.Item1), part2Position.Item2 - 1)),
            'R' => (part2Position.Item1, Math.Min(4 - Math.Abs(2 - part2Position.Item1), part2Position.Item2 + 1)),
            _ => throw new ArgumentException($"Unable to understand the direction \"{c}\"."),
        };
    }
    part1Code += PART1_KEYPAD[part1Position.Item1, part1Position.Item2];
    part2Code += PART2_KEYPAD[part2Position.Item1, part2Position.Item2];
}

Console.WriteLine($"Part 1: {part1Code}");
Console.WriteLine($"Part 2: {part2Code}");
