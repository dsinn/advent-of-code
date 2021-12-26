using System.IO;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;

class Helper {
    public static string GetAllInputText([CallerFilePath] string filePath = "") {
        return File.ReadAllText(ReplacePathExtensionWithTxt(filePath)).Trim();
    }

    public static IEnumerable<string> GetInputLineEnumerable([CallerFilePath] string filePath = "") {
        using (StreamReader sr = new StreamReader(ReplacePathExtensionWithTxt(filePath))) {
            string line;
            while ((line = sr.ReadLine()) != null) {
                yield return line;
            }
        }
    }

    private static string ReplacePathExtensionWithTxt(string filePath) {
        return Regex.Replace(filePath, "\\.csx$", ".txt");
    }
}
