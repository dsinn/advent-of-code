#!/usr/bin/env php
<?php
$original_matches = [];

$f = fopen(__DIR__ . '/07.txt', 'r');
while ($line = rtrim(fgets($f))) {
    if (!preg_match('/^(.*?) -> ([a-z]+)$/', $line, $matches)) {
        throw new UnexpectedValueException("Unable to understand the instruction \"{$line}\"");
    }
    $original_matches[] = $matches;
}
fclose($f);

// @TODO Use toposort to make this O(n) instead of O(n^2)

function eval_token(array $wires, string $token): int {
    if (is_numeric($token)) {
        return intval($token, 10);
    }
    if (!isset($wires[$token])) {
        throw new OutOfBoundsException("The {$token} wire has not yet been connected.");
    }
    return $wires[$token];
}

$last_wire_a = null;
foreach ([1, 2] as $part) {
    $wires = [];
    $matches_copy = $original_matches;

    while ($matches = array_shift($matches_copy)) {
        $wire = $matches[2];
        $tokens = explode(' ', $matches[1]);

        if (isset($last_wire_a) && $wire == 'b') {
            $value = $last_wire_a;
        } else {
            try {
                $value = match(count($tokens)) {
                    1 => eval_token($wires, $tokens[0]),
                    2 => ~eval_token($wires, $tokens[1]),
                    3 => call_user_func(function () use ($wires, $tokens) {
                        $operand1 = eval_token($wires, $tokens[0]);
                        $operand2 = eval_token($wires, $tokens[2]);
                        return match ($tokens[1]) {
                            'AND' => $operand1 & $operand2,
                            'LSHIFT' => $operand1 << $operand2,
                            'RSHIFT' => $operand1 >> $operand2,
                            'OR' => $operand1 | $operand2,
                        };
                    }),
                };
            } catch (OutOfBoundsException $_) {
                $matches_copy[] = $matches;
                //echo $_ . PHP_EOL;
                //print_r($matches_copy);
                continue;
            }
        }

        $wires[$wire] = $value & 65535;
    }
    echo "Part {$part}: {$wires['a']}" . PHP_EOL;
    $last_wire_a = $wires['a'];
}
