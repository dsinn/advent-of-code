#!/usr/bin/env php
<?php
list($raw_replacements, $medicine) = explode("\n\n", rtrim(file_get_contents(__DIR__ . '/19.txt')));

foreach (explode("\n", $raw_replacements) as $raw_replacement) {
    list($search, $replace) = explode(' => ', $raw_replacement);
    $replacements[$search][] = $replace;
    $flipped_replacements[$replace] = $search;
}

$distinct_molecules = [];
foreach ($replacements as $search => $replaces) {
    $offset = 0;
    while ($pos = strpos($medicine, $search, $offset)) {
        foreach ($replaces as $replace) {
            $distinct_molecules[substr_replace($medicine, $replace, $pos, strlen($search))] = true;
        }
        $offset = $pos + 1;
    }
}

echo 'Part 1: ' . count($distinct_molecules) . PHP_EOL;

/**
 * Precondition: $flipped_replacements' keys are ordered by non-increasing string length
 * (This way, the algorithm can be greedy.)
 */
function fewestSteps(array $flipped_replacements, string $medicine, int $steps, int &$fewest_steps)
{
    if ($fewest_steps) {
        // "Stop all recursion" flag enabled once we find the answer
        return;
    }

    if ($medicine === 'e') {
        $fewest_steps = $steps;
        return;
    }

    foreach ($flipped_replacements as $search => $replace) {
        if (($pos = strpos($medicine, $search)) === false) {
            continue;
        }

        $new_medicine = substr_replace($medicine, $replace, $pos, strlen($search));
        fewestSteps($flipped_replacements, $new_medicine, $steps + 1, $fewest_steps);
    }
}

uksort($flipped_replacements, fn($a, $b) => strlen($b) <=> strlen($a));

$fewest_steps = 0;
fewestSteps($flipped_replacements, $medicine, 0, $fewest_steps);

echo "Part 2: {$fewest_steps}" . PHP_EOL;
