#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/16.txt', 'r');

$sues = [];

while ($line = rtrim(fgets($f))) {
    if (!preg_match('/^Sue (\d+): *(.+)$/i', $line, $matches)) {
        throw new UnexpectedValueException('Unable to parse the following line: ' . PHP_EOL . $line);
    }

    foreach (explode(', ', $matches[2]) as $raw_pair) {
        $tokens = explode(': ', $raw_pair);
        $quantity = intval($tokens[1], 10);
        $sues[$matches[1]][$tokens[0]] = $quantity;
    }
}
fclose($f);

$ticker = [
    'children'      => 3,
    'cats'          => 7,
    'samoyeds'      => 2,
    'pomeranians'   => 3,
    'akitas'        => 0,
    'vizslas'       => 0,
    'goldfish'      => 5,
    'trees'         => 3,
    'cars'          => 2,
    'perfumes'      => 1,
];

foreach ($sues as $sue_number => $belongings) {
    if ($belongings == array_intersect_key($ticker, $belongings)) {
        echo "Part 1: {$sue_number}" . PHP_EOL;
        break;
    }
}

$exact_ticker = array_diff_key($ticker, array_fill_keys(['cats', 'trees', 'pomeranians', 'goldfish'], true));

foreach ($sues as $sue_number => $belongings) {
    if (array_intersect_key($belongings, $exact_ticker) == array_intersect_key($exact_ticker, $belongings)
        && $ticker['cats'] < ($belongings['cats'] ?? PHP_INT_MAX)
        && $ticker['trees'] < ($belongings['trees'] ?? PHP_INT_MAX)
        && $ticker['pomeranians'] > ($belongings['pomeranians'] ?? 0)
        && $ticker['goldfish'] > ($belongings['goldfish'] ?? 0)
    ) {
        echo "Part 2: {$sue_number}" . PHP_EOL;
        break;
    }
}
