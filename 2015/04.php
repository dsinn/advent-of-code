#!/usr/bin/env php
<?php
$secret = rtrim(file_get_contents(__DIR__ . '/04.txt'));
$i = 0;

while (!preg_match('/^00000/', md5("{$secret}{$i}"))) {
    $i += 1;
}
echo "Part 1: {$i}" . PHP_EOL;

while (!preg_match('/^000000/', md5("{$secret}{$i}"))) {
    $i += 1;
}
echo "Part 2: {$i}" . PHP_EOL;
