#!/usr/bin/env python3
from itertools import product
from os.path import dirname
from queue import PriorityQueue

f = open(f'{dirname(__file__)}/15.txt', 'r')

risk_levels = list(
    map(
        lambda line: list(map(lambda raw_risk_level: int(raw_risk_level), list(line.rstrip()))),
        f.readlines()
    )
)

# Dijkstra's algorithm, adapted for this problem
def lowest_risk(risk_levels):
    distances = {node:float('inf') for node in product(range(len(risk_levels)), range(len(risk_levels[0])))}
    distances[(0, 0)] = 0

    to_visit = PriorityQueue()
    to_visit.put((0, 0), 0)

    while not to_visit.empty():
        node = to_visit.get()
        for offset in [(0, 1), (1, 0), (0, -1), (-1, 0)]:
            i = node[0] + offset[0]
            j = node[1] + offset[1]
            if not (i, j) in distances:
                continue

            neighbour_distance = distances[node] + risk_levels[i][j]
            if neighbour_distance < distances[(i, j)]:
                distances[(i, j)] = neighbour_distance
                to_visit.put((i, j), neighbour_distance)
    return list(distances.values())[-1]

print(f'Part 1: {lowest_risk(risk_levels)}')

def increment_risk(level):
    return 1 if level == 9 else level + 1

original_height = len(risk_levels)
original_width = len(risk_levels[0])
for _ in range(4):
    for i in range(original_height):
        risk_levels.append(list(map(increment_risk, risk_levels[-original_height])))
for i in range(len(risk_levels)):
    for j in range(len(risk_levels[i]) * 4):
        risk_levels[i].append(increment_risk(risk_levels[i][-original_width]))

print(f'Part 2: {lowest_risk(risk_levels)}')
