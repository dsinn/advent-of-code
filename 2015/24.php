#!/usr/bin/env php
<?php
$weights = array_map(fn($line) => intval($line, 10), file(__DIR__ . '/24.txt', FILE_IGNORE_NEW_LINES));

/**
 * Precondition: int[] $weights is in descending order.
 * (This way, the algorithm can be greedy.)
 */
function subsetSumBestQE(
    array $weights,
    array $weights_flipped,
    int $target,
    int &$best_qe,
    int &$best_legroom_used = PHP_INT_MAX,
    int $qe = 1,
    int $legroom_used = 0,
    int $start_index = 0
): void {
    if ($target < 0 || $legroom_used > $best_legroom_used) {
        return;
    }

    // Use the array indexed by weight to skip one loop
    if (($weights_flipped[$target] ?? -1) >= $start_index) {
        $qe *= $target;
        $legroom_used++;

        if ($best_legroom_used > $legroom_used || $best_qe > $qe) {
            $best_legroom_used = $legroom_used;
            $best_qe = $qe;
        }

        return;
    }

    for ($i = $start_index; $i < count($weights); $i++) {
        $weight = $weights[$i];
        subsetSumBestQE(
            $weights,
            $weights_flipped,
            $target - $weight,
            $best_qe,
            $best_legroom_used,
            $qe * $weight,
            $legroom_used + 1,
            $i + 1
        );
    }
}

rsort($weights); // Convenience for the subsetSumBestQE precondition
$weight_sum = array_sum($weights);
$weights_flipped = array_flip($weights);
$part1_qe = $part2_qe = PHP_INT_MAX;

subsetSumBestQE($weights, $weights_flipped, $weight_sum / 3, $part1_qe);
echo "Part 1: {$part1_qe}" . PHP_EOL;

subsetSumBestQE($weights, $weights_flipped, $weight_sum / 4, $part2_qe);
echo "Part 2: {$part2_qe}" . PHP_EOL;
