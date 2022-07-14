#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/08.txt', 'r');

$password = 'RUN EVAL';

echo <<<WARNING
Warning: `eval` will be used on each line of the input file. To continue,
please carefully read each line of 08.txt, and only if you're sure it's safe,
type in "{$password}" (without quotes) and hit enter:


WARNING;

$user_input = readline();
echo PHP_EOL;
if ($user_input !== $password) {
    echo "Aborting because input \"{$user_input}\" does not equal \"{$password}\"." . PHP_EOL;
    exit;
}

$part1 = $part2 = 0;
while ($line = rtrim(fgets($f))) {
    $original_length = strlen($line);
    $part1 += $original_length - strlen(eval("return {$line};"));
    $part2 += strlen(addslashes($line)) - $original_length + 2;
}
fclose($f);

echo "Part 1: {$part1}" . PHP_EOL;
echo "Part 2: {$part2}" . PHP_EOL;
