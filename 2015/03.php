#!/usr/bin/env php
<?php
$part1_set = ['0,0' => true];
$x = $y = 0;

$part2_set = ['0,0' => true];
$part2_positions = [[0, 0], [0, 0]];
$santa_index = 0;

foreach (str_split(rtrim(file_get_contents(__DIR__ . '/03.txt'))) as $dir) {
    if ($dir == '^') {
        $y -= 1;
        $part2_positions[$santa_index][1] -= 1;
    } elseif ($dir == 'v') {
        $y += 1;
        $part2_positions[$santa_index][1] += 1;
    } elseif ($dir == '>') {
        $x += 1;
        $part2_positions[$santa_index][0] += 1;
    } elseif ($dir == '<') {
        $x -= 1;
        $part2_positions[$santa_index][0] -= 1;
    }

    $part1_key = "{$x},{$y}";
    $part1_set[$part1_key] = true;

    $part2_key = "";
    $part2_set[implode(',', $part2_positions[$santa_index])] = true;
    $santa_index = 1 - $santa_index;
}

echo 'Part 1: ' . count($part1_set) . PHP_EOL;
echo 'Part 2: ' . count($part2_set) . PHP_EOL;
