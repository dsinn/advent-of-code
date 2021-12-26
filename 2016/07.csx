#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Text.RegularExpressions;

readonly string ABBA = @"([a-z])(?!\1)([a-z])\2\1";
readonly string ABA = @"([a-z])(?!\1)(?=[a-z]\1)";

int tlsCount = 0, sslCount = 0;

foreach (string line in Helper.GetInputLineEnumerable()) {
    string supernet = Regex.Replace(line, @"\[[^\]]+\]", " ");
    string hypernet = Regex.Replace(line, @"^[^\[]*\[|\][^\[]*\[|\][^\[]*$", " ");
    if (
        Regex.Match(supernet, ABBA).Success &&
        !Regex.Match(hypernet, ABBA).Success
    ) {
        tlsCount++;
    }

    foreach (Match aba in Regex.Matches(supernet, ABA)) {
        string bab = $"{supernet[aba.Index + 1]}{supernet[aba.Index]}{supernet[aba.Index + 1]}";
        if (hypernet.Contains(bab)) {
            sslCount++;
            break;
        }
    }
}

Console.WriteLine($"Part 1: {tlsCount}");
Console.WriteLine($"Part 2: {sslCount}");
