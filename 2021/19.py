#!/usr/bin/env python3
from collections import defaultdict
import functools
from math import cos, pi, sin
from os.path import dirname
import re

# @TODO omg this is so inefficient. Fix it xD

def build_rotation_matrices():
    rotation_matrices = []
    for roll in range(4):
        c = roll * pi / 2
        for yaw in range(4):
            a = yaw * pi / 2
            rotation_matrices.append([
                [cos(a), -sin(a) * cos(c),  sin(a) * sin(c)],
                [sin(a),  cos(a) * cos(c), -cos(a) * sin(c)],
                [     0,           sin(c),           cos(c)]
            ])
        for pitch in range(1, 4, 2):
            b = pitch * pi / 2
            rotation_matrices.append([
                [ cos(b), sin(b) * sin(c), sin(b) * cos(c)],
                [      0,          cos(c),         -sin(c)],
                [-sin(b), cos(b) * sin(c), cos(b) * cos(c)]
            ])
    return [
        [
            [round(number) for number in row]
            for row in matrix
        ] for matrix in rotation_matrices
    ]

def add(v1, v2):
    if len(v1) != len(v2):
        raise ValueError(f'Addition is undefined for vectors of different lengths: {v1} (length {len(v1)}) and {v2} (length {len(v2)}).')
    return [v1[i] + v2[i] for i in range(len(v1))]

def dot_product(v1, v2):
    if len(v1) != len(v2):
        raise ValueError(f'Dot product is undefined for vectors of different lengths: {v1} (length {len(v1)}) and {v2} (length {len(v2)}).')
    return functools.reduce(lambda sum, i: sum + v1[i] * v2[i], range(len(v1)), 0)

def multiply(matrix, vector):
    return [dot_product(row, vector) for row in matrix]

def subtract(v1, v2):
    if len(v1) != len(v2):
        raise ValueError(f'Subtraction is undefined for vectors of different lengths: {v1} (length {len(v1)}) and {v2} (length {len(v2)}).')
    return [v1[i] - v2[i] for i in range(len(v1))]

rotation_matrices = build_rotation_matrices()

f = open(f'{dirname(__file__)}/19.txt', 'r')

scanners = [
    [
        [int(raw_coord) for raw_coord in raw_line.split(',')] for raw_line in raw_beacons.split('\n')
    ] for raw_beacons in re.split(r'\s*--- scanner \d+ ---\s*', f.read().rstrip())[1:]
]

# Initialize with scanner 0 as the "absolute" reference
absolute_beacons = set()
for beacon in scanners[0]:
    absolute_beacons.add(tuple(beacon))

scanner_offsets = [[0, 0, 0]]
scanner_indices_to_check = list(range(1, len(scanners)))
while scanner_indices_to_check:
    scanner_index = scanner_indices_to_check.pop(0)
    print(f'Checking scanner {scanner_index}... ', end = '')
    scanner = scanners[scanner_index]
    # Determine which rotation matrix leads to the most matches of offsets wrt what we know so far
    best_translation = None
    best_translation_common = 1
    best_offset = None
    for matrix in rotation_matrices:
        rotated_beacons = [multiply(matrix, beacon) for beacon in scanner]
        for absolute_beacon in iter(absolute_beacons):
            for rotated_beacon in rotated_beacons:
                # Pretend absolute beacon == rotated beacon, see what happens
                offset = subtract(absolute_beacon, rotated_beacon)
                translated_beacons = set()
                for rotated_beacon2 in rotated_beacons:
                    translated_beacons.add(tuple(add(rotated_beacon2, offset)))

                # Check how many translations match absolute_beacons
                common_count = len(translated_beacons.intersection(absolute_beacons))
                if best_translation_common < common_count:
                    best_translation_common = common_count
                    best_translation = translated_beacons
                    best_offset = offset

    if best_translation:
        absolute_beacons = absolute_beacons.union(best_translation)
        scanner_offsets.append(best_offset)
        print(f'found {best_translation_common} existing beacons using offset {best_offset}')
    else:
        # There are no overlaps with what we have so far; try later after checking more scanners
        print(f'skipping because there is no overlap')
        scanner_indices_to_check.append(scanner_index)

print(f'Part 1: {len(absolute_beacons)}')

max_distance = 0
for i in range(len(scanner_offsets)):
    for j in range(i + 1, len(scanner_offsets)):
        diff = subtract(scanner_offsets[i], scanner_offsets[j])
        max_distance = max(max_distance, abs(diff[0]) + abs(diff[1]) + abs(diff[2]))
print(f'Part 2: {max_distance}')
