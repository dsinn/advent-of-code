#!/usr/bin/env php
<?php
$part1_state = array_fill(0, 1000, array_fill(0, 1000, false));
$part1_action = [
    'turn on' => fn(bool $_): bool => true,
    'toggle' => fn(bool $state): bool => !$state,
    'turn off' => fn(bool $_): bool => false,
];

$brightnesses = array_fill(0, 1000, array_fill(0, 1000, 0));
$part2_action = [
    'turn on' => fn(int $brightness): int => $brightness + 1,
    'toggle' => fn(int $brightness): int => $brightness + 2,
    'turn off' => fn(int $brightness): int => max(0, $brightness - 1),
];

$f = fopen(__DIR__ . '/06.txt', 'r');
while ($line = rtrim(fgets($f))) {
    if (!preg_match('/^(.*?) (\d+),(\d+) through (\d+),(\d+)$/', $line, $matches)) {
        throw new UnexpectedValueException("Unable to understand the instruction \"{$line}\"");
    }

    $coords = array_map(fn(string $regex_group): int => intval($regex_group, 10), array_slice($matches, 2));
    for ($i = $coords[0]; $i <= $coords[2]; $i++) {
        for ($j = $coords[1]; $j <= $coords[3]; $j++) {
            $part1_state[$i][$j] = $part1_action[$matches[1]]($part1_state[$i][$j]);
            $brightnesses[$i][$j] = $part2_action[$matches[1]]($brightnesses[$i][$j]);
        }
    }
}
fclose($f);

echo 'Part 1: ' . array_sum(array_map(fn(array $row): int => count(array_filter($row)), $part1_state)) . PHP_EOL;
echo 'Part 2: ' . array_sum(array_map('array_sum', $brightnesses)) . PHP_EOL;
