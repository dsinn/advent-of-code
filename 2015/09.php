#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/09.txt', 'r');

$distances = [];
while ($line = rtrim(fgets($f))) {
    if (!preg_match('/(\S+) to (\S+) = (\d+)$/', $line, $matches)) {
        throw new UnexpectedValueException('Unable to parse the following line: ' . PHP_EOL . $line);
    }

    $distance = intval(intval($matches[3], 10));
    $distances[$matches[1]][$matches[2]] = $distance;
    $distances[$matches[2]][$matches[1]] = $distance;
}
fclose($f);

function travelingSalesman(array $distances, string $last_visited, array $to_visit, int $distance) {
    if (!$to_visit) {
        global $shortest, $longest;
        $shortest = min($shortest, $distance);
        $longest = max($longest, $distance);
        return;
    }

    foreach ($to_visit as $location => $_) {
        travelingSalesman(
            $distances,
            $location,
            array_diff_key($to_visit, [$location => true]),
            $last_visited ? $distance + $distances[$last_visited][$location] : 0
        );
    }
}

$to_visit = array_fill_keys(array_keys($distances), true);
$shortest = PHP_INT_MAX;
$longest = 0;
travelingSalesman($distances, '', $to_visit, 0);

echo "Part 1: {$shortest}" . PHP_EOL;
echo "Part 2: {$longest}" . PHP_EOL;
