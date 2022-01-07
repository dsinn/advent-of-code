#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Text.RegularExpressions;

bool[,] pixels = new bool[6, 50];
foreach (string line in Helper.GetInputLineEnumerable()) {
    Match match;
    if ((match = Regex.Match(line, @"^rect (\d+)x(\d+)$")).Success) {
        int width = Int32.Parse(match.Groups[1].Value);
        int height = Int32.Parse(match.Groups[2].Value);
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                pixels[i, j] = true;
            }
        }
    } else if ((match = Regex.Match(line, @"rotate column x=(\d+) by (\d+)")).Success) {
        int column = Int32.Parse(match.Groups[1].Value);
        int rotations = Int32.Parse(match.Groups[2].Value);
        bool[] newColumn = new bool[pixels.GetLength(0)];
        for (int i = 0; i < pixels.GetLength(0); i++) {
            newColumn[(i + rotations) % pixels.GetLength(0)] = pixels[i, column];
        }
        for (int i = 0; i < pixels.GetLength(0); i++) {
            pixels[i, column] = newColumn[i];
        }
    } else if ((match = Regex.Match(line, @"rotate row y=(\d+) by (\d+)")).Success) {
        int row = Int32.Parse(match.Groups[1].Value);
        int rotations = Int32.Parse(match.Groups[2].Value);
        bool[] newRow = new bool[pixels.GetLength(1)];
        for (int j = 0; j < pixels.GetLength(1); j++) {
            newRow[(j + rotations) % pixels.GetLength(1)] = pixels[row, j];
        }
        for (int j = 0; j < pixels.GetLength(1); j++) {
            pixels[row, j] = newRow[j];
        }
    }
}

int lit = 0;
for (int i = 0; i < pixels.GetLength(0); i++) {
    for (int j = 0; j < pixels.GetLength(1); j++) {
        if (pixels[i, j]) {
            lit++;
            Console.Write('#');
        } else {
            Console.Write('.');
        }
    }
    Console.WriteLine();
}
Console.WriteLine($"Part 1: {lit}")
