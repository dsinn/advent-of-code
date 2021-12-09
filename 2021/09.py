#!/usr/bin/env python3
f = open('09.txt', 'r')

heights = list(
    map(
        lambda line: list(map(lambda raw_height: int(raw_height), list(line.rstrip()))),
        f.readlines()
    )
)

def get_basin_size(heights, row, col, previous_height = -1, basin_points = None):
    if not basin_points:
        basin_points = {}
    if (row, col) in basin_points:
        return

    try:
        height = heights[row][col]
    except IndexError:
        return
    if height == 9 or height < previous_height:
        return

    basin_points[(row, col)] = True

    get_basin_size(heights, row - 1, col, height, basin_points)
    get_basin_size(heights, row + 1, col, height, basin_points)
    get_basin_size(heights, row, col - 1, height, basin_points)
    get_basin_size(heights, row, col + 1, height, basin_points)

    return len(basin_points)

risk_level = 0
basin_sizes = []
for i in range(len(heights)):
    for j in range(len(heights[i])):
        if (
            (i == 0 or heights[i][j] < heights[i - 1][j]) and
            (i + 1 >= len(heights) or heights[i][j] < heights[i + 1][j]) and
            (j == 0 or heights[i][j] < heights[i][j - 1]) and
            (j + 1 >= len(heights[i]) or heights[i][j] < heights[i][j + 1])
        ):
            risk_level += 1 + heights[i][j]
            basin_sizes.append(get_basin_size(heights, i, j))
basin_sizes.sort()

print(f'Part 1: {risk_level}')
print(f'Part 2: {basin_sizes[-1] * basin_sizes[-2] * basin_sizes[-3]}')
