#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/15.txt', 'r');

define('CALORIES_KEY', 'calories');

$properties = [];
$ingredientsAsKeys = [];
while ($line = rtrim(fgets($f))) {
    if (!preg_match('/^([^:]+): *(.+)$/i', $line, $matches)) {
        throw new UnexpectedValueException('Unable to parse the following line: ' . PHP_EOL . $line);
    }

    $ingredient = $matches[1];
    $ingredientsAsKeys[$ingredient] = true;
    foreach (explode(', ', $matches[2]) as $raw_pair) {
        $tokens = explode(' ', $raw_pair);
        if (($quantity = intval($tokens[1], 10)) !== 0) {
            $properties[$tokens[0]][$ingredient] = $quantity;
        }
    }
}
fclose($f);

function score(array $ingredients, array $properties): int
{
    $score = 1;
    foreach ($properties as $property => $propertyMapping) {
        if ($property === CALORIES_KEY) {
            continue;
        }

        $propertyScore = 0;
        foreach ($propertyMapping as $ingredient => $coefficient) {
            $propertyScore += $coefficient * $ingredients[$ingredient];
        }
        $score *= max(0, $propertyScore);
    }
    return $score;
}

function calories(array $ingredients, array $properties): int
{
    $calories = 0;
    foreach ($properties[CALORIES_KEY] as $ingredient => $coefficient) {
        $calories += $coefficient * $ingredients[$ingredient];
    }
    return $calories;
}

function bruteForce(
    int $teaspoonsLeft,
    array $ingredientsLeft,
    array $ingredientsUsed,
    array $properties,
    int &$part1Score,
    int &$part2Score,
) {
    $nextIngredientsLeft = $ingredientsLeft;
    $ingredient = array_shift($nextIngredientsLeft);

    if (!$nextIngredientsLeft) {
        $finalIngredients = $ingredientsUsed + [$ingredient => $teaspoonsLeft];
        $score = score($finalIngredients, $properties);

        $part1Score = max($part1Score, $score);
        if (calories($finalIngredients, $properties) === 500) {
            $part2Score = max($part2Score, $score);
        }

        return;
    }

    for ($i = $teaspoonsLeft; $i >= 0; $i--) {
        bruteForce(
            $teaspoonsLeft - $i,
            $nextIngredientsLeft,
            $ingredientsUsed + [$ingredient => $i],
            $properties,
            $part1Score,
            $part2Score
        );
    }
}

$part1Score = $part2Score = 0;
bruteForce(100, array_keys($ingredientsAsKeys), [], $properties, $part1Score, $part2Score);

echo "Part 1: {$part1Score}" . PHP_EOL;
echo "Part 2: {$part2Score}" . PHP_EOL;
