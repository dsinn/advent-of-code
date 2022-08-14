#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/17.txt', 'r');

$containers = [];
while ($line = rtrim(fgets($f))) {
    $containers[] = intval($line, 10);
}
fclose($f);

function bruteForce(
    array $containers,
    int $litresRemaining,
    int $i,
    int $containersUsed,
    array &$countsByContainersUsed
) {
    if ($i >= count($containers)) {
        return;
    }

    bruteForce($containers, $litresRemaining, $i + 1, $containersUsed, $countsByContainersUsed);

    $containersUsed++;
    if ($containers[$i] === $litresRemaining) {
        $countsByContainersUsed[$containersUsed] = ($countsByContainersUsed[$containersUsed] ?? 0) + 1;
        return;
    } else if ($containers[$i] < $litresRemaining) {
        bruteForce($containers, $litresRemaining - $containers[$i], $i + 1, $containersUsed, $countsByContainersUsed);
    }
}

$countsByContainersUsed = [];
bruteForce($containers, 150, 0, 0, $countsByContainersUsed);

$part1 = array_sum($countsByContainersUsed);
echo "Part 1: {$part1}" . PHP_EOL;

$part2 = $countsByContainersUsed[min(array_keys($countsByContainersUsed))];
echo "Part 2: {$part2}" . PHP_EOL;
