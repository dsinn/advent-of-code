#!/usr/bin/env python3
from os.path import dirname

f = open(f'{dirname(__file__)}/02.txt', 'r')

positions = [{'horizontal': 0, 'depth': 0} for _ in range(2)]
aim = 0

for line in f.readlines():
    direction, magnitude = line.split(' ')
    magnitude = int(magnitude)
    match direction:
        case 'forward':
            for position in positions:
                position['horizontal'] += magnitude
            positions[1]['depth'] += aim * magnitude
        case 'up':
            positions[0]['depth'] -= magnitude
            aim -= magnitude
        case 'down':
            positions[0]['depth'] += magnitude
            aim += magnitude
        case _:
            raise ValueError(f'"{direction}" is not a recognized direction string.')

for i, position in enumerate(positions):
    print(f'Part {i + 1}: {position["horizontal"] * position["depth"]}')
