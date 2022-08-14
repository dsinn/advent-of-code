#!/usr/bin/env php
<?php
define('LENGTH', 100);

$initial_state = array_fill(0, LENGTH, array_fill(0, LENGTH, false));

$f = fopen(__DIR__ . '/18.txt', 'r');
$row = 0;
while ($line = rtrim(fgets($f))) {
    foreach (str_split($line) as $col => $char) {
        $initial_state[$row][$col] = $char === '#';
    }
    $row++;
}
fclose($f);

function countActiveNeighbours(array $part1_state, int $row, int $col): int
{
    $count = 0;
    for ($i = $row - 1; $i <= $row + 1; $i++) {
        for ($j = $col - 1; $j <= $col + 1; $j++) {
            if ($part1_state[$i][$j] ?? false) {
                $count++;
            }
        }
    }
    return $count - ($part1_state[$row][$col] ? 1 : 0);
}

$part1_state = $initial_state;
for ($step = 0; $step < 100; $step++) {
    $next_state = $part1_state;
    for ($row = 0; $row < LENGTH; $row++) {
        for ($col = 0; $col < LENGTH; $col++) {
            $next_state[$row][$col] = in_array(
                countActiveNeighbours($part1_state, $row, $col),
                $part1_state[$row][$col] ? [2, 3] : [3]
            );
        }
    }
    $part1_state = $next_state;
}
echo 'Part 1: ' . array_sum(array_map(fn(array $row): int => count(array_filter($row)), $part1_state)) . PHP_EOL;

$part2_state = $initial_state;
$part2_state[0][0] = true;
$part2_state[0][LENGTH - 1] = true;
$part2_state[LENGTH - 1][0] = true;
$part2_state[LENGTH - 1][LENGTH - 1] = true;
for ($step = 0; $step < 100; $step++) {
    $next_state = $part2_state;
    for ($row = 0; $row < LENGTH; $row++) {
        for ($col = 0; $col < LENGTH; $col++) {
            $next_state[$row][$col] = in_array($row, [0, LENGTH - 1]) && in_array($col, [0, LENGTH - 1])
                || in_array(
                    countActiveNeighbours($part2_state, $row, $col),
                    $part2_state[$row][$col] ? [2, 3] : [3]
                );
        }
    }
    $part2_state = $next_state;
}
echo 'Part 2: ' . array_sum(array_map(fn(array $row): int => count(array_filter($row)), $part2_state)) . PHP_EOL;
