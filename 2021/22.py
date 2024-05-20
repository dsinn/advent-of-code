#!/usr/bin/env python3
import functools
from os.path import dirname
import array
import re
import warnings # oof

f = open(f'{dirname(__file__)}/22.txt', 'r')

warnings.warn("This took my machine several minutes to execute on non-test data.")

x_set, y_set, z_set = [set() for _ in range(3)]
instructions = []

for line in f.readlines():
    match = re.match(r'(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)', line)
    if not match:
        raise ValueError(f'Unable to parse instruction "{line}"')

    x_min, x_max, y_min, y_max, z_min, z_max = [int(raw_coord) for raw_coord in match.groups()[1:]]

    instructions.append({
        'x_min': x_min,
        'y_min': y_min,
        'z_min': z_min,
        'x_max': x_max + 1,
        'y_max': y_max + 1,
        'z_max': z_max + 1,
        'state': match.group(1) == 'on'
    })

    x_set.add(x_min)
    y_set.add(y_min)
    z_set.add(z_min)
    x_set.add(x_max + 1)
    y_set.add(y_max + 1)
    z_set.add(z_max + 1)

x_sorted, y_sorted, z_sorted = [array.array('i', sorted(points)) for points in [x_set, y_set, z_set]]
x_map, y_map, z_map = [{point: index for index, point in enumerate(points)} for points in [x_sorted, y_sorted, z_sorted]]

state = [[[False for _ in range(len(z_sorted))] for _ in range(len(y_sorted))] for _ in range(len(x_sorted))]

for instruction in instructions:
    for x in range(x_map[instruction['x_min']], x_map[instruction['x_max']]):
        for y in range(y_map[instruction['y_min']], y_map[instruction['y_max']]):
            for z in range(z_map[instruction['z_min']], z_map[instruction['z_max']]):
                state[x][y][z] = instruction['state']

part1 = 0
part2 = 0
for x in range(len(x_sorted) - 1):
    for y in range(len(y_sorted) - 1):
        for z in range(len(z_sorted) - 1):
            if state[x][y][z]:
                part2 += (x_sorted[x + 1] - x_sorted[x]) * (y_sorted[y + 1] - y_sorted[y]) * (z_sorted[z + 1] - z_sorted[z])

                x_min, y_min, z_min = [max(-50, min(50, pos)) for pos in [x_sorted[x], y_sorted[y], z_sorted[z]]]
                x_max, y_max, z_max = [max(-50, min(50, pos)) for pos in [x_sorted[x + 1], y_sorted[y + 1], z_sorted[z + 1]]]
                part1 += (x_max - x_min) * (y_max - y_min) * (z_max - z_min)

print(f'Part 1: {part1}')
print(f'Part 2: {part2}')
