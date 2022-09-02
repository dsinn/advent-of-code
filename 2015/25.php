#!/usr/bin/env php
<?php
if (!preg_match('/row (\d++), column (\d++)/', $file_contents = file_get_contents(__DIR__ . '/25.txt'), $matches)) {
    throw new UnexpectedValueException("Unable to find the row and column in the string \"{$file_contents}\"");
}
list(, $row, $column) = $matches;

$diagonal = $row + $column;
$code_index = (($diagonal - 2) * ($diagonal - 1) / 2 + $column) % 33554393; // Column 1 grows quadratically
// 252533 and 33554393 are coprime, so we can't cut any more corners

$code = 20151125;
for ($i = 1; $i < $code_index; $i++) {
    $code = $code * 252533 % 33554393;
}

echo $code . PHP_EOL;
