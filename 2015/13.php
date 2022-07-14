#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/13.txt', 'r');

$adjacency_scores = [];
while ($line = rtrim(fgets($f))) {
    if (!preg_match('/^(?<who>\S+) would (?<sign>gain|lose) (?<abs_value>\d+) happiness units by sitting next to (?<whom>\S+)\.$/', $line, $matches)) {
        throw new UnexpectedValueException('Unable to parse the following line: ' . PHP_EOL . $line);
    }

    $amount = ($matches['sign'] === 'gain' ? 1 : -1) * intval($matches['abs_value'], 10);
    $adjacency_scores[$matches['who']][$matches['whom']] = $amount;
}
fclose($f);

function findOptimalHappiness(array $adjacency_scores, array $order, array $people_left) {
    if (!$people_left) {
        $happiness_with_me = array_sum(
            array_map(
                function ($i) use ($adjacency_scores, $order) {
                    $person = $order[$i];
                    $next_person = $order[$i + 1];
                    return $adjacency_scores[$person][$next_person] + $adjacency_scores[$next_person][$person];
                },
                range(0, count($order) - 2),
            )
        );

        $person1_beside_me = reset($order);
        $person2_beside_me = end($order);
        $happiness_without_me = array_sum([
            $happiness_with_me,
            $adjacency_scores[$person1_beside_me][$person2_beside_me],
            $adjacency_scores[$person2_beside_me][$person1_beside_me]
        ]);

        global $optimal_happiness_without_me, $optimal_happiness_with_me;
        $optimal_happiness_without_me = max($optimal_happiness_without_me, $happiness_without_me);
        $optimal_happiness_with_me = max($optimal_happiness_with_me, $happiness_with_me);
        return;
    }

    foreach ($people_left as $person => $_) {
        findOptimalHappiness(
            $adjacency_scores,
            array_merge($order, [$person]),
            array_diff_key($people_left, [$person => true])
        );
    }
}

$people = array_fill_keys(array_keys($adjacency_scores), true);
// In part 1 we could do (n - 1)! checks instead of n! by fixing any one person as the "first" the circle,
// but alas, part 2 we fix ourselves as the "first."
$order = [];

$optimal_happiness_without_me = 0;
$optimal_happiness_with_me = 0;
findOptimalHappiness($adjacency_scores, $order, $people);

echo "Part 1: {$optimal_happiness_without_me}" . PHP_EOL;
echo "Part 2: {$optimal_happiness_with_me}" . PHP_EOL;
