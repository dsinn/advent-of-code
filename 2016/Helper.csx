using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;

class Helper {
    public static string GetAllInputText([CallerFilePath] string filePath = "") {
        return File.ReadAllText(ReplacePathExtensionWithTxt(filePath)).Trim();
    }

    private static string ReplacePathExtensionWithTxt(string filePath) {
        return Regex.Replace(filePath, "\\.csx$", ".txt");
    }
}
