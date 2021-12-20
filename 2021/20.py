#!/usr/bin/env python3
from os.path import dirname

f = open(f'{dirname(__file__)}/20.txt', 'r')

algorithm = [pixel == '#' for pixel in ''.join(f.readline().rstrip())]

# When 3x3 dark pixels map to a light pixel and 3x3 light pixels map to a dark pixel, weird shit happens
flip_mode = algorithm[0] and not algorithm[-1]

f.readline()
raw_image = f.read().rstrip()
raw_image_rows = raw_image.split('\n')

lit = set()
for i in range(len(raw_image_rows)):
    for j in range(len(raw_image_rows[i])):
        if raw_image_rows[i][j] == '#':
            lit.add((j, i))
min_x = 0
max_x = len(raw_image_rows[0]) - 1
min_y = 0
max_y = len(raw_image_rows) - 1

for iteration in range(1, 51):
    infinitely_light = flip_mode and iteration % 2 == 0
    new_lit = set()
    new_min_x = min_x
    new_max_x = max_x
    new_min_y = min_y
    new_max_y = max_y
    for j in range(min_x - 1, max_x + 2):
        for i in range(min_y - 1, max_y + 2):
            binary_string = ''
            for b_i in range(i - 1, i + 2):
                for b_j in range(j - 1, j + 2):
                    if (
                        (b_j, b_i) in lit or
                        infinitely_light and not (min_y <= b_i <= max_y and min_x <= b_j <= max_x)
                    ):
                        binary_string += '1'
                    else:
                        binary_string += '0'
            algorithm_index = int(binary_string, 2)
            if algorithm[algorithm_index]:
                new_lit.add((j, i))
                new_min_x = min(new_min_x, j)
                new_max_x = max(new_max_x, j)
                new_min_y = min(new_min_y, i)
                new_max_y = max(new_max_y, i)
    lit = new_lit
    min_x = new_min_x
    max_x = new_max_x
    min_y = new_min_y
    max_y = new_max_y

    if iteration == 2:
        print(f'Part 1: {len(lit)}')

    # for i in range(min_y, max_y + 1):
    #     for j in range(min_x, max_x + 1):
    #         print('#' if (j, i) in lit else '.', end = '')
    #     print('')
    # print('')

print(f'Part 2: {len(lit)}')
