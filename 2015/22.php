#!/usr/bin/env php
<?php
class Character
{
    private array $effects = [];

    public function __construct(private Stats $stats) { }

    public function __clone(): void
    {
        $this->effects = array_map(fn(Effect $effect) => clone $effect, $this->effects);
        $this->stats = clone $this->stats;
    }

    public function addEffect(string $name, Effect $effect): void
    {
        $this->effects[$name] = $effect;
        $effect->start($this->stats);
    }

    public function applyEffects(): void
    {
        foreach ($this->effects as $name => $effect) {
            if ($effect->tick($this->stats) <= 0) {
                unset($this->effects[$name]);
            }
        }
    }

    public function getEffects(): array
    {
        return $this->effects;
    }

    public function getStats(): Stats
    {
        return $this->stats;
    }
}

class Stats
{
    public function __construct(public int $hp = 0, public int $dmg = 0, public int $arm = 0, public int $mp = 0) { }
}

abstract class Spell
{
    public function __construct(protected string $name, private int $mp_cost) { }

    public function canCast(Character $caster, Character $enemy): bool
    {
        return $this->mp_cost <= $caster->getStats()->mp;
    }

    public function getMPCost(): int
    {
        return $this->mp_cost;
    }

    abstract public function doCast(Character $caster, Character $enemy): void;
}

class Effect
{
    public function __construct(private int $duration) { }

    public function start(Stats $target_stats): void { }

    public function tick(Stats $target_stats): int
    {
        if (--$this->duration <= 0) {
            $this->end($target_stats);
        }
        return $this->duration;
    }

    protected function end(Stats $target_stats): void { }
}

abstract class EffectSpell extends Spell
{
    public function canCast(Character $caster, Character $enemy): bool
    {
        return parent::canCast($caster, $enemy) && !isset($this->getTarget($caster, $enemy)->getEffects[$this->name]);
    }

    public function doCast(Character $caster, Character $enemy): void
    {
        $this->getTarget($caster, $enemy)->addEffect($this->name, $this->getEffect());
    }

    abstract protected function getEffect(): Effect;
    abstract protected function getTarget(Character $caster, Character $enemy): Character;
}

abstract class BuffSpell extends EffectSpell
{
    protected function getTarget(Character $caster, Character $_enemy): Character
    {
        return $caster;
    }
}

abstract class DebuffSpell extends EffectSpell
{
    protected function getTarget(Character $_caster, Character $enemy): Character
    {
        return $enemy;
    }
}

function calcLowestMPCost(
    Character $player,
    Character $boss,
    array $spell_list,
    int $hp_loss_per_turn,
    int $current_cost = 0,
    int &$lowest_cost = PHP_INT_MAX,
): int
{
    // Beginning of player's turn
    $player->applyEffects();
    $player->getStats()->hp -= $hp_loss_per_turn;
    if ($player->getStats()->hp <= 0) {
        return $lowest_cost;
    }

    $boss->applyEffects();

    if ($boss->getStats()->hp <= 0) {
        return ($lowest_cost = $current_cost);
    }

    // Pick the next spell to cast
    foreach ($spell_list as $spell) {
        if (!$spell->canCast($player, $boss)) {
            continue;
        }

        $spell_cost = $spell->getMPCost();
        $new_cost = $current_cost + $spell_cost;
        if ($new_cost > $lowest_cost) {
            continue;
        }

        $player_clone = clone $player;
        $boss_clone = clone $boss;

        $player_clone->getStats()->mp -= $spell_cost;
        $spell->doCast($player_clone, $boss_clone);

        // Beginning of boss's turn
        $player_clone->applyEffects();
        $boss_clone->applyEffects();

        if ($boss_clone->getStats()->hp <= 0) {
            $lowest_cost = $new_cost;
            continue;
        }

        // Boss attacks player
        $player_clone->getStats()->hp -= max(1, $boss_clone->getStats()->dmg - $player_clone->getStats()->arm);
        if ($player_clone->getStats()->hp > 0) {
            calcLowestMPCost($player_clone, $boss_clone, $spell_list, $hp_loss_per_turn, $new_cost, $lowest_cost);
        }
    }

    return $lowest_cost;
}

$spell_list = [
    new class(name: "Magic Missile", mp_cost: 53) extends Spell
    {
        public function doCast(Character $_caster, Character $enemy): void
        {
            $enemy->getStats()->hp -= 4;
        }
    },
    new class(name: "Drain", mp_cost: 73) extends Spell
    {
        public function doCast(Character $caster, Character $enemy): void
        {
            $caster->getStats()->hp += 2;
            $enemy->getStats()->hp -= 2;
        }
    },
    new class(name: "Shield", mp_cost: 113) extends BuffSpell
    {
        protected function getEffect(): Effect
        {
            return new class(duration: 6) extends Effect
            {
                private int $arm_bonus = 7;

                public function start(Stats $target_stats): void
                {
                    $target_stats->arm += $this->arm_bonus;
                }

                public function end(Stats $target_stats): void
                {
                    $target_stats->arm -= $this->arm_bonus;
                }
            };
        }
    },
    new class(name: "Poison", mp_cost: 173) extends DebuffSpell
    {
        protected function getEffect(): Effect
        {
            return new class(duration: 6) extends Effect
            {
                public function tick(Stats $target_stats): int
                {
                    $target_stats->hp -= 3;
                    return parent::tick($target_stats);
                }
            };
        }
    },
    new class(name: "Recharge", mp_cost: 229) extends BuffSpell
    {
        protected function getEffect(): Effect
        {
            return new class(duration: 5) extends Effect
            {
                public function tick(Stats $target_stats): int
                {
                    $target_stats->mp += 101;
                    return parent::tick($target_stats);
                }
            };
        }
    },
];

preg_match_all('/\\d++/', file_get_contents(__DIR__ . '/22.txt'), $matches);
$boss = new Character(
    new Stats(...array_map(fn(string $match) => intval($match, 10), $matches[0]))
);
$player = new Character(new Stats(hp: 50, mp: 500));

foreach (range(1, 2) as $part) {
    echo "Part {$part}: " . calcLowestMPCost($player, $boss, $spell_list, $part - 1) . PHP_EOL;
}
