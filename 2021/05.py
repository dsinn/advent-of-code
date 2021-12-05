#!/usr/bin/env python3
from collections import defaultdict
import re

f = open('05.txt', 'r')

part1_frequency_map = defaultdict(lambda: 0)
part1_overlap_points = 0

part2_frequency_map = defaultdict(lambda: 0)
part2_overlap_points = 0

for line in f.readlines():
    x1, y1, x2, y2 = list(
        map(
            lambda raw_coord: int(raw_coord),
            re.search('^(\d+),(\d+) -> (\d+),(\d+)$', line).groups()
        )
    )
    is_diagonal = x1 != x2 and y1 != y2
    x_step = (x2 > x1) - (x2 < x1)
    y_step = (y2 > y1) - (y2 < y1)
    for i in range(max(abs(x2 - x1), abs(y2 - y1)) + 1):
        x = x1 + i * x_step
        y = y1 + i * y_step
        part2_frequency_map[(x, y)] += 1
        if part2_frequency_map[(x, y)] == 2:
            part2_overlap_points += 1
        if not is_diagonal:
            part1_frequency_map[(x, y)] += 1
            if part1_frequency_map[(x, y)] == 2:
                part1_overlap_points += 1


print(f'Part 1: {part1_overlap_points}')
print(f'Part 2: {part2_overlap_points}')
