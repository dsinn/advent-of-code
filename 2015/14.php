#!/usr/bin/env php
<?php
$f = fopen(__DIR__ . '/14.txt', 'r');

define('TARGET_TIME', 2503);

class Reindeer
{
    public int $distance = 0;
    public int $points = 0;

    private int $period;
    private int $periodic_distance;
    private float $periodic_speed;

    public function __construct(private int $burst_speed, private int $burst_duration, private int $rest_duration)
    {
        $this->period = $burst_duration + $rest_duration;
        $this->periodic_distance = $burst_duration * $burst_speed;
        $this->periodic_speed = $this->periodic_distance / $this->period;
    }

    public function getBurstDuration(): int
    {
        return $this->burst_duration;
    }

    public function getBurstSpeed(): int
    {
        return $this->burst_speed;
    }

    public function getPeriod(): int
    {
        return $this->period;
    }

    public function getPeriodicDistance(): int
    {
        return $this->periodic_distance;
    }

    public function getPeriodicSpeed(): float
    {
        return $this->periodic_speed;
    }

    public function getRestDuration(): int
    {
        return $this->rest_duration;
    }
}

$reindeers = [];
while ($line = rtrim(fgets($f))) {
    if (
        !preg_match(
            '/^(?:\S+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds\.$/',
            $line,
            $matches
        )
    ) {
        throw new UnexpectedValueException('Unable to parse the following line: ' . PHP_EOL . $line);
    }

    $reindeers[] = new Reindeer($matches[1], $matches[2], $matches[3]);
}
fclose($f);

$part1 = max(
    array_map(
        fn ($r) => $r->getPeriodicDistance() * intdiv(TARGET_TIME, $r->getPeriod())
                + $r->getBurstSpeed() * min($r->getBurstDuration(), TARGET_TIME % $r->getPeriod()),
        $reindeers
    )
);

echo "Part 1: {$part1}" . PHP_EOL;

// @TODO Use some linear math to calculate Part 2's scores by chunks of cycles instead of individual seconds
for ($t = 0; $t < 2503; $t++) {
    foreach ($reindeers as $r) {
        if ($t % $r->getPeriod() < $r->getBurstDuration()) {
            $r->distance += $r->getBurstSpeed();
        }
    }

    $leaders = [];
    $best_distance = 0;
    foreach ($reindeers as $i => $r) {
        if ($best_distance < $r->distance) {
            $best_distance = $r->distance;
            $leaders = [$i];
        } else if ($best_distance === $r->distance) {
            $leaders[] = $i;
        }
    }

    foreach ($leaders as $i) {
        $reindeers[$i]->points++;
    }
}

$part2 = max(array_map(fn ($r) => $r->points, $reindeers));
echo "Part 2: {$part2}" . PHP_EOL;
