#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Linq;

List<int>[] triangles = {new List<int>(), new List<int>(), new List<int>()};

foreach (string line in Helper.GetInputLineEnumerable()) {
    int column = 0;
    foreach (string token in line.Split(' ', StringSplitOptions.RemoveEmptyEntries)) {
        triangles[column++].Add(Int32.Parse(token));
    }
}

static bool isValidTriangle(int a, int b, int c) {
    int[] lengths = new int[] {a, b, c};
    Array.Sort(lengths);
    return lengths[0] + lengths[1] > lengths[2];
}

int part1Count = 0;
for (int i = 0; i < triangles[0].Count(); i++) {
    if (isValidTriangle(triangles[0].ElementAt(i), triangles[1].ElementAt(i), triangles[2].ElementAt(i))) {
        part1Count++;
    }
}
Console.WriteLine($"Part 1: {part1Count}");

int part2Count = 0;
for (int i = 0; i < triangles[0].Count(); i += 3) {
    for (int j = 0; j < 3; j++) {
        if (isValidTriangle(
            triangles[j].ElementAt(i),
            triangles[j].ElementAt(i + 1),
            triangles[j].ElementAt(i + 2)
        )) {
            part2Count++;
        }
    }
}
Console.WriteLine($"Part 2: {part2Count}");
