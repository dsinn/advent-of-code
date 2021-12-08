#!/usr/bin/env python3
import functools
f = open('07.txt', 'r')

def calculate_cost(positions, destination, fuel_by_distance_lambda):
    total_cost = 0
    for position in positions:
        total_cost += fuel_by_distance_lambda(abs(destination - position))
    return total_cost

positions = list(map(lambda raw_position: int(raw_position), f.read().rstrip().split(',')))
positions.sort() # There are O(n) ways of finding the median, but 🤷‍♀️
median = positions[len(positions) // 2]
print(f'Part 1: {calculate_cost(positions, median, lambda dist: dist)}')

# For part 2, just assume that the optimal solution lies *somewhere* between the median and average.
# Would use math to go under O(n^2) but that takes intelligence xD
def triangular_number(x):
    return x * (x + 1) // 2

average = round(sum(positions) / len(positions))
best_cost = functools.reduce(
    lambda best_cost, destination:
        min(best_cost, calculate_cost(positions, destination, lambda dist: triangular_number(dist))),
    range(min(average, median), max(average, median) + 1),
    float('inf')
)
print(f'Part 2: {best_cost}')
