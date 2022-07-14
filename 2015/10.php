#!/usr/bin/env php
<?php
$sequence = rtrim(file_get_contents(__DIR__ . '/10.txt'));

function lookAndSay(string $sequence): string {
    return preg_replace_callback('/((.)+?)(?!\\2)/', fn($matches) => strlen($matches[1]) . $matches[2], $sequence);
}

for ($i = 0; $i < 40; $i++) {
    $sequence = lookAndSay($sequence);
}
echo 'Part 1: ' . strlen($sequence) . PHP_EOL;

for ($i = 0; $i < 10; $i++) {
    $sequence = lookAndSay($sequence);
}
echo 'Part 2: ' . strlen($sequence) . PHP_EOL;
