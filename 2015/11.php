#!/usr/bin/env php
<?php
define('ALPHABET', preg_replace('/[iol]/', '', implode('', array_map(fn($i) => chr(96 + $i), range(1, 26)))));
define('ALPHABET_LENGTH', strlen(ALPHABET));
define(
    'TRIPLETS',
    '/' . implode('|', array_map(fn($i) => substr(ALPHABET, $i, 3), range(0, strlen(ALPHABET) - 3))) . '/'
);
define('TWO_PAIRS', "/(.)\\1.*(.)(?=\\2)(?!\\1)/");

function toInt(string $password): int {
    $result = 0;
    foreach (str_split($password, 1) as $char) {
        $result *= ALPHABET_LENGTH;
        $result += strpos(ALPHABET, $char);
    }
    return $result;
}

function toString(int $int): string {
    $length = strlen(ALPHABET);
    $result = '';
    while ($int) {
        $result = ALPHABET[$int % $length] . $result;
        $int = intdiv($int, $length);
    }
    return $result;
}

function nextPassword(string $password): string {
    $int = toInt($password);
    do {
        $password = toString(++$int, ALPHABET);
    } while (!preg_match(TRIPLETS, $password) || !preg_match(TWO_PAIRS, $password));

    return $password;
}

$password = rtrim(file_get_contents(__DIR__ . '/11.txt'));

$password = nextPassword($password);
echo "Part 1: {$password}" . PHP_EOL;

$password = nextPassword($password);
echo "Part 2: {$password}" . PHP_EOL;
