#!/usr/bin/env php
<?php
class Character
{
    public function __construct(private Stats $stats) { }

    public function defeats(Character $enemy): bool
    {
        $my_attacks_needed = self::hitsToKill(attacker: $this, defender: $enemy);
        $enemy_attacks_needed = self::hitsToKill(defender: $this, attacker: $enemy);
        return $my_attacks_needed <= $enemy_attacks_needed;
    }

    public function getStats(): Stats
    {
        return $this->stats;
    }

    private static function hitsToKill(Character $attacker, Character $defender): int
    {
        return ceil($defender->getStats()->hp / max(1, $attacker->getStats()->dmg - $defender->getStats()->arm));
    }
}

class Player extends Character
{
    private $equipment_list;
    private $final_stats;

    public function __construct(private Stats $stats)
    {
        $this->resetEquipment();
    }

    public function addEquipment(Equipment $equipment): void
    {
        $this->equipment_list[] = $equipment;
        foreach (get_object_vars($equipment->modifiers) as $attr => $modifier) {
            $this->final_stats->$attr += $modifier;
        }
    }

    public function getStats(): Stats
    {
        return $this->final_stats;
    }

    public function resetEquipment(): void
    {
        $this->equipment_list = [];
        $this->final_stats = new Stats(...get_object_vars($this->stats));
    }

    public function setEquipment(array $new_equipment_list): void
    {
        $this->resetEquipment();
        foreach ($new_equipment_list as $equipment) {
            $this->addEquipment($equipment);
        }
    }
}

class Equipment
{
    public function __construct(private string $name, private int $cost, public Stats $modifiers) { }

    public function getCost(): int
    {
        return $this->cost;
    }

    public function getName(): string
    {
        return $this->name;
    }
}

class Stats
{
    public function __construct(public int $hp = 0, public int $dmg = 0, public int $arm = 0) { }

    public function add(Stats $stats): Stats
    {
        return new Stats(
            ...array_map(
                fn(string $stat) => $this->$stat + $stats->$stat,
                array_keys(get_object_vars($this))
            )
        );
    }
}

function chooseBetween(int $min, int $max, array $stock, array $result = [], int $start_index = 0): Generator
{
    if (count($result) <= $max) {
        yield $result;
    }

    if (count($result) == $max) {
        return;
    }

    $upper_bound = count($stock) - $max + count($result) + 1;
    for ($i = $start_index; $i < $upper_bound; $i++) {
        yield from chooseBetween($min, $max, $stock, array_merge($result, [$stock[$i]]), $i + 1);
    }
}

preg_match_all('/\\d++/', file_get_contents(__DIR__ . '/21.txt'), $matches);
$boss = new Character(
    new Stats(...array_map(fn(string $match) => intval($match, 10), $matches[0]))
);
$player = new Player(new Stats(hp: 100));

$weapons = [
    new Equipment('Dagger', 8, new Stats(dmg: 4)),
    new Equipment('Shortsword', 8, new Stats(dmg: 5)),
    new Equipment('Warhammer', 25, new Stats(dmg: 6)),
    new Equipment('Longsword', 40, new Stats(dmg: 7)),
    new Equipment('Greataxe', 74, new Stats(dmg: 8)),
];

$armours = [
    new Equipment('Leather', 13, new Stats(arm: 1)),
    new Equipment('Chainmail', 31, new Stats(arm: 2)),
    new Equipment('Splintmail', 53, new Stats(arm: 3)),
    new Equipment('Bandedmail', 75, new Stats(arm: 4)),
    new Equipment('Platemail', 102, new Stats(arm: 5)),
];

$offhands = [
    new Equipment('Damage +1', 25, new Stats(dmg: 1)),
    new Equipment('Damage +2', 50, new Stats(dmg: 2)),
    new Equipment('Damage +3', 100, new Stats(dmg: 3)),
    new Equipment('Defence +1', 25, new Stats(arm: 1)),
    new Equipment('Defence +2', 40, new Stats(arm: 2)),
    new Equipment('Defence +3', 80, new Stats(arm: 3)),
];

$winning_equipment = $losing_equipment = [];
$lowest_cost_winning = PHP_INT_MAX;
$highest_cost_losing = PHP_INT_MIN;

foreach ($weapons as $weapon) {
    foreach (chooseBetween(0, 1, $armours) as $chosen_armours) {
        foreach (chooseBetween(0, 2, $offhands) as $chosen_offhands) {
            $chosen_equipment = array_merge([$weapon], $chosen_armours, $chosen_offhands);
            $cost = array_sum(
                array_map(
                    fn(Equipment $equipment) => $equipment->getCost(),
                    $chosen_equipment
                )
            );

            if ($lowest_cost_winning > $cost) {
                $player->setEquipment($chosen_equipment);

                if ($player->defeats($boss)) {
                    $lowest_cost_winning = $cost;
                    $winning_equipment = $chosen_equipment;
                }
            }

            if ($highest_cost_losing < $cost) {
                $player->setEquipment($chosen_equipment);

                if (!$player->defeats($boss)) {
                    $highest_cost_losing = $cost;
                    $losing_equipment = $chosen_equipment;
                }
            }
        }
    }
}

foreach ([
    ['answer' => $lowest_cost_winning, 'equipment' => $winning_equipment],
    ['answer' => $highest_cost_losing, 'equipment' => $losing_equipment],
] as $i => ['answer' => $answer, 'equipment' => $equipment]) {
    printf(
        "Part %d: %d (%s)" . PHP_EOL,
        $i + 1,
        $answer,
        implode(', ', array_map(fn(Equipment $e) => $e->getName(), $equipment))
    );
}
