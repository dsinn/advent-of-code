#!/usr/bin/env php
<?php
$wrapping_paper = $ribbon = 0;
$f = fopen(__DIR__ . '/02.txt', 'r');
while ($line = fgets($f)) {
    $dims = array_map('intval', explode('x', rtrim($line)));
    $areas = [$dims[0] * $dims[1], $dims[0] * $dims[2], $dims[1] * $dims[2]];
    $wrapping_paper += (array_sum($areas) << 1) + min($areas);

    sort($dims);
    $ribbon += ($dims[0] + $dims[1] << 1) + array_product($dims);
}
fclose($f);

echo "Part 1: {$wrapping_paper}" . PHP_EOL;
echo "Part 2: {$ribbon}" . PHP_EOL;
