#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Text.RegularExpressions;

delegate long Callback(string data, Callback callback);

static long CalculateDecompressedLength(string data, Callback callback) {
    long result = data.Length;
    int head = 0;
    while (true) {
        int iLeftBracket = data.IndexOf('(', head);
        if (iLeftBracket == -1) {
            break;
        }

        int iRightBracket = data.IndexOf(')', iLeftBracket + 1);

        Match decompression = Regex.Match(data.Substring(iLeftBracket + 1, iRightBracket - iLeftBracket - 1), @"(\d+)x(\d+)");
        int repeatingCharCount = Int32.Parse(decompression.Groups[1].Value);
        int repetitions = Int32.Parse(decompression.Groups[2].Value);

        string repeatedString = data.Substring(iRightBracket + 1, repeatingCharCount);
        result += callback(repeatedString, callback) * repetitions - (iRightBracket + 1 - iLeftBracket) - repeatingCharCount;
        head = iRightBracket + 1 + repeatingCharCount;
    }
    return result;
}

string data = Helper.GetAllInputText();
Console.WriteLine($"Part 1: {CalculateDecompressedLength(data, (data, _callback) => data.Length)}");
Console.WriteLine($"Part 2: {CalculateDecompressedLength(data, CalculateDecompressedLength)}");
