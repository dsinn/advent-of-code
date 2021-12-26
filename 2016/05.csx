#!/usr/bin/env dotnet-script
#load "Helper.csx"
using System.Security.Cryptography;

string doorID = Helper.GetAllInputText();

string password1 = "";
char[] password2 = new char[8];
int password2CharsLeft = password2.Length;

MD5 md5 = MD5.Create();
int i = 0;
while (password2CharsLeft > 0) {
    byte[] inputBytes = Encoding.ASCII.GetBytes($"{doorID}{i++}");
    byte[] digest = md5.ComputeHash(inputBytes);
    string thirdByteString;
    if (
        digest[0] == 0 && // 00
        digest[1] == 0 && // 00
        (thirdByteString = BitConverter.ToString(new byte[] {digest[2]})).StartsWith("0") // 0*
    ) {
        if (password1.Length < 8) {
            password1 += thirdByteString[1];
        }

        try {
            int position = Int32.Parse(thirdByteString.Substring(1));
            if (position < password2.Length && password2[position] == '\0') {
                password2CharsLeft--;
                password2[position] = BitConverter.ToString(new byte[] {digest[3]})[0];
            }
        } catch (FormatException) {
        }
    }
}

Console.WriteLine($"Part 1: {password1.ToLower()}");
Console.WriteLine($"Part 2: {String.Join("", password2).ToLower()}");
