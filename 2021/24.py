#!/usr/bin/env python3
from os.path import dirname
import re

f = open(f'{dirname(__file__)}/24.txt', 'r')
instructions = f.read()

x_offsets = [int(string) for string in re.findall(r'^add x (-?\d+)$', instructions, re.MULTILINE)]
y_offsets = [int(string) for string in re.findall(r'add y w\nadd y (-?\d+)', instructions)]
z_grows = [divisor == '1' for divisor in re.findall(r'div z (-?\d+)', instructions, re.MULTILINE)]

pairs = []
stack = []
for i, is_growing in enumerate(z_grows):
    if is_growing:
        stack.append(i)
    else:
        pairs.append((stack.pop(), i))

part1 = [-1,] * len(z_grows)
part2 = part1.copy()

for left, right in pairs:
    difference = y_offsets[left] + x_offsets[right]
    if difference > 0:
        part1[left] = 9 - difference
        part1[right] = 9
        part2[left] = 1
        part2[right] = 1 + difference
    else:
        part1[left] = 9
        part1[right] = 9 + difference
        part2[left] = 1 - difference
        part2[right] = 1

for i, part in enumerate([part1, part2]):
    print(f'Part {i + 1}: {"".join([str(digit) for digit in part])}')
