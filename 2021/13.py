#!/usr/bin/env python3
import re
f = open('13.txt', 'r')

dot_positions = []
max_x = max_y = 0
while True:
    line = f.readline().rstrip()
    if not line:
        break
    position = tuple(map(lambda raw_coord: int(raw_coord), line.split(',')))
    x, y = position
    max_x = max(x, max_x)
    max_y = max(y, max_y)
    dot_positions.append(position)

grid = [([False,] * (max_x + 1)) for _ in range(max_y + 1)]
for pos in dot_positions:
    grid[pos[1]][pos[0]] = True

def apply_fold(grid, row_to_fold):
    height = len(grid)
    try:
        i = 1
        while True:
            upper_row_index = row_to_fold - i
            lower_row_index = row_to_fold + i
            for j in range(len(grid[i])):
                grid[upper_row_index][j] = grid[upper_row_index][j] or grid[lower_row_index][j]
            i += 1
    except IndexError:
        return grid[0:row_to_fold]

# For performance, we could instead keep track of how many dots are visible and update for each fold
def count_visible_dots(grid):
    return sum(list(map(lambda row: row.count(True), grid)))

def transpose(grid):
    return list(map(list, zip(*grid)))

part1 = True
while True:
    line = f.readline().rstrip()
    if not line:
        break

    axis, raw_value = re.search('^fold along ([xy])=(\d+)$', line).groups()
    value = int(raw_value)
    if axis == 'x':
        grid = transpose(apply_fold(transpose(grid), value))
    else:
        grid = apply_fold(grid, value)

    if part1:
        print(f'Part 1: {count_visible_dots(grid)}')
        part1 = False

print('\nPart 2:')
for row in grid:
    for is_dot in row:
        print('#' if is_dot else ' ', end = '')
    print('')
