#!/usr/bin/env python3
from os.path import dirname
import re

f = open(f'{dirname(__file__)}/21.txt', 'r')

original_pos = [int(re.search(r'\d+$', f.readline().rstrip()).group()) for _ in range(2)]
scores = [0, 0]

pos = original_pos.copy()
increment = 6
turn = 1
rolls = 0
while scores[turn] < 1000:
    turn = 1 - turn
    rolls += 3
    pos[turn] += increment
    scores[turn] += (pos[turn] - 1) % 10 + 1
    increment += 9
print(f'Part 1: {min(scores) * rolls}')

UNIVERSES_BY_SUM = {
    3: 1, # 1+1+1
    4: 3, # 2+1+1
    5: 6, # 3 (3+1+1) + 3 (2+2+1)
    6: 7, # 6 (3+2+1) + 1 (2+2+2)
    7: 6, # rest is symmetric
    8: 3,
    9: 1
}

def part2(winning_universes, current_universes, scores, pos, turn):
    for sum in range(3, 10):
        next_pos = pos.copy()
        next_pos[turn] += sum
        next_scores = scores.copy()
        next_scores[turn] += (next_pos[turn] - 1) % 10 + 1
        next_universes = current_universes * UNIVERSES_BY_SUM[sum]
        if next_scores[turn] >= 21:
            winning_universes[turn] += next_universes
        else:
            part2(winning_universes, next_universes, next_scores, next_pos, 1 - turn)

winning_universes = [0, 0]
part2(winning_universes, 1, [0, 0], original_pos.copy(), 0)
print(f'Part 2: {max(winning_universes)}')
