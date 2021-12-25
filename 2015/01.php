#!/usr/bin/env php
<?php
$floor = 0;
$part2 = false;
foreach (str_split(rtrim(file_get_contents(__DIR__ . '/01.txt'))) as $i => $c) {
    if ($c == '(') {
        $floor++;
    } else {
        $floor--;
        if (!$part2 && $floor < 0) {
            $part2 = $i + 1;
        }
    }
}

echo "Part 1: {$floor}" . PHP_EOL;
echo "Part 2: {$part2}" . PHP_EOL;
