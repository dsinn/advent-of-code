#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Security.Cryptography;

Dictionary<char, int>[] freq = new Dictionary<char, int>[8];
for (int i = 0; i < freq.Length; i++) {
    freq[i] = new Dictionary<char, int>();
}

foreach (string line in Helper.GetInputLineEnumerable()) {
    for (int i = 0; i < line.Length; i++) {
        int currentCount;
        freq[i].TryGetValue(line[i], out currentCount);
        freq[i][line[i]] = currentCount + 1;
    }
}

Console.Write("Part 1: ");
foreach (Dictionary<char, int> column in freq) {
    Console.Write(column.Aggregate((a, b) => a.Value > b.Value ? a : b).Key);
}
Console.WriteLine();

Console.Write("Part 2: ");
foreach (Dictionary<char, int> column in freq) {
    Console.Write(column.Aggregate((a, b) => a.Value < b.Value ? a : b).Key);
}
Console.WriteLine();
