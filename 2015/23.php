#!/usr/bin/env php
<?php
$inst = file(__DIR__ . '/23.txt', FILE_IGNORE_NEW_LINES);

foreach ([1, 2] as $part) {
    $register = ['a' => $part - 1, 'b' => 0];

    $offset = 0;
    while (isset($inst[$offset])) {
        $tokens = preg_split('/,? /', $inst[$offset]);
        switch ($tokens[0]) {
            case 'hlf':
                $register[$tokens[1]] /= 2;
                $offset++;
                break;
            case 'tpl':
                $register[$tokens[1]] *= 3;
                $offset++;
                break;
            case 'inc':
                $register[$tokens[1]]++;
                $offset++;
                break;
            case 'jmp':
                $offset += intval($tokens[1], 10);
                break;
            case 'jie':
                $offset += ($register[$tokens[1]] % 2 === 0) ? intval($tokens[2], 10) : 1;
                break;
            case 'jio':
                $offset += ($register[$tokens[1]] === 1) ? intval($tokens[2], 10) : 1;
                break;
            default:
                throw new UnexpectedValueException("{$tokens[0]} is not a recognized instruction.");
        }
    }

    echo "Part {$part}: {$register['b']}" . PHP_EOL;
}
