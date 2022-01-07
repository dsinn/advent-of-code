#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Text.RegularExpressions;

int realRoomIDSum = 0, part2ID = -1;
foreach (string line in Helper.GetInputLineEnumerable()) {
    Match match = Regex.Match(line, @"^([a-z-]+)(\d+)\[([a-z]+)\]$");
    if (!match.Success) {
        throw new ArgumentException($"Unable to understand the room \"{line}\".");
    }

    string encryptedName = match.Groups[1].Value.Trim('-');
    Dictionary<char, int> freq = new Dictionary<char, int>();
    foreach (char c in encryptedName.Replace("-", "")) {
        int currentCount;
        freq.TryGetValue(c, out currentCount);
        freq[c] = currentCount + 1;
    }

    string checksum = match.Groups[3].Value;
    char[] charsByFrequency = (from entry in freq orderby entry.Value descending, entry.Key select entry.Key).ToArray();

    if (String.Join("", charsByFrequency).StartsWith(checksum)) {
        int sectorID = Int32.Parse(match.Groups[2].Value);
        realRoomIDSum += sectorID;

        int rotMagnitude = sectorID % 26;
        string decryptedName = "";
        foreach (char c in encryptedName) {
            decryptedName += c switch {
                '-' => ' ',
                _ when 'a' <= c && c <= 'z' => (char) ((c + rotMagnitude - 'a') % 26 + 'a'),
                _ => new ArgumentException($"Unexpected character '{c}' in {encryptedName}"),
            };
        }
        Console.WriteLine($"{decryptedName} -> {sectorID}"); // These _need_ to be printed since they're fun

        if (decryptedName == "northpole object storage") {
            part2ID = sectorID;
        }
    }
}

Console.WriteLine();
Console.WriteLine($"Part 1: {realRoomIDSum}");
Console.WriteLine($"Part 2: {part2ID}");
