#!/usr/bin/env php
<?php
$part1_count = $part2_count = 0;
$f = fopen(__DIR__ . '/05.txt', 'r');
while ($line = rtrim(fgets($f))) {
    if (
        preg_match_all('/[aeiou]/', $line, $matches) &&
        count($matches[0]) >= 3 &&
        preg_match('/(.)\1/', $line) &&
        !preg_match('/ab|cd|pq|xy/', $line)
    ) {
        $part1_count++;
    }
    if (preg_match('/(.{2}).*\1/', $line) && preg_match('/(.).\1/', $line)) {
        $part2_count++;
    }
}
fclose($f);

echo "Part 1: {$part1_count}" . PHP_EOL;
echo "Part 2: {$part2_count}" . PHP_EOL;
