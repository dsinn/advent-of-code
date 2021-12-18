#!/usr/bin/env python3
import functools
import math
from os.path import dirname
import re

def add(snail1, snail2):
    return reduce(f'[{snail1},{snail2}]')

def explode(snail, head):
    match = re.match('\[(\d+),(\d+)\]\D+(\d+)?', snail[head:])
    left_number = int(match.group(1), 10)
    right_number = int(match.group(2), 10)

    # Substitute from right to left so that we don't have to handle changing indices

    if match.start(3) > -1:
        # Add to right neighbour
        snail = f'{snail[0:head + match.start(3)]}{right_number + int(match.group(3), 10)}{snail[(head + match.end(3)):]}'

    # Substitute with 0
    snail = f'{snail[0:head]}0{snail[(head + match.end(2) + 1):]}'

    left_ints = list(re.finditer(r'\d+', snail[0:head]))
    if left_ints:
        # Add to left neighbour
        left_neighbour = left_ints[-1]
        snail = f'{snail[0:left_neighbour.start()]}{left_number + int(left_neighbour.group(), 10)}{snail[left_neighbour.end():]}'

    return snail

def magnitude(snail):
    if isinstance(snail, str):
        snail = eval(snail)
    if isinstance(snail, list):
        return 3 * magnitude(snail[0]) + 2 * magnitude(snail[1])
    if isinstance(snail, int):
        return snail
    raise ValueError(f'Magnitude of {snail} (type {type(snail)}) is undefined.')

def reduce(snail):
    something_exploded = True
    split_match = None
    while something_exploded or split_match:
        something_exploded = False

        # Explode
        head = 0
        depth = 0
        while head < len(snail):
            if snail[head] == '[':
                if depth < 4:
                    depth += 1
                else:
                    something_exploded = True
                    snail = explode(snail, head)
            elif snail[head] == ']':
                depth -= 1
            head += 1

        # Split
        split_match = re.search(r'\d{2,}', snail)
        if split_match:
            half = int(split_match.group()) / 2
            snail = f'{snail[0:split_match.start()]}[{math.floor(half)},{math.ceil(half)}]{snail[split_match.end():]}'
    return snail

f = open(f'{dirname(__file__)}/18.txt', 'r')
snails = [line.rstrip() for line in f.readlines()]
print(f'Part 1: {magnitude(functools.reduce(add, snails))}')

largest_pair_sum = 0
for i in range(len(snails)):
    for j in range(i + 1, len(snails)):
        largest_pair_sum = max(
            largest_pair_sum,
            magnitude(add(snails[i], snails[j])),
            magnitude(add(snails[j], snails[i]))
        )

print(f'Part 2: {largest_pair_sum}')
