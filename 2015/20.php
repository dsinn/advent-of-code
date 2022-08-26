#!/usr/bin/env php
<?php
$input = intval(rtrim(file_get_contents(__DIR__ . '/20.txt')), 10);

(function () use ($input) {
    // To avoid repeatedly multiplying by the number of presents given, divide the puzzle input by that number up front
    $threshold = ceil($input / 10);
    $present_counts = array_fill(1, $threshold, 1);

    for ($elf = 2; $elf < $threshold; $elf++) { // Skip elf #1 because we passed value=1 into array_fill
        for ($house = $elf; $house <= $threshold; $house += $elf) {
            $present_counts[$house] += $elf;
        }
    }

    foreach ($present_counts as $house => $present_count) {
        if ($present_count >= $threshold) {
            echo "Part 1: {$house}" . PHP_EOL;
            return;
        }
    }
})();

(function () use ($input) {
    $threshold = ceil($input / 11);
    $present_counts = array_fill(1, $threshold, 0);

    for ($elf = 1; $elf < $threshold; $elf++) {
        $house = 0;
        for ($i = 0; $i < min(50, intdiv($threshold, $elf)); $i++) {
            $house += $elf;
            $present_counts[$house] += $elf;
        }
    }

    foreach ($present_counts as $house => $present_count) {
        if ($present_count >= $threshold) {
            echo "Part 2: {$house}" . PHP_EOL;
            return;
        }
    }
})();
