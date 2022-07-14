#!/usr/bin/env php
<?php
$object = json_decode(rtrim(file_get_contents(__DIR__ . '/12.txt')), true);

$sum = 0;
array_walk_recursive(
    $object,
    function ($value) {
        global $sum;
        if (is_int($value)) {
            $sum += $value;
        }
    }
);
echo "Part 1: {$sum}" . PHP_EOL;

function nonRedSum($value) {
    if (is_int($value)) {
        return $value;
    }
    if (is_array($value)) {
        if (isAssociative($value) && in_array('red', $value)) {
            return 0;
        }
        return array_sum(
            array_map(fn($value) => nonRedSum($value), $value)
        );
    }
}

function isAssociative(array $array): bool {
    foreach (array_keys($array) as $k => $v) {
        if ($k !== $v) {
          return true;
        }
    }
    return false;
}

echo 'Part 2: ' . nonRedSum($object) . PHP_EOL;
