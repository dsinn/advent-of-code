#!/usr/bin/env python3
import math
from os.path import dirname
import re

f = open(f'{dirname(__file__)}/17.txt', 'r')
x_target_min, x_target_max, y_target_min, y_target_max = [int(group) for group in re.search('^target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)$', f.read().rstrip()).groups()]

highest_success_apex = 0
successful_initial_velocity_count = 0

# For simplicity, assume x_target_min and x_target_max are always positive while
# y_target_min and y_target_max are always negative.

# For a given x0, the highest x is the x0'th triangular number because of drag. Use the quadratic formula (from the
# triangular number equation) to determine the lowest x0 that doesn't fall completely short of the target.
#
# x_target_min = x0_min(x0_min + 1) / 2
# 2 * x_target_min = x0_min^2 + x0_min
# x0_min^2 + x0_min - 2 * x_target_min = 0
x0_min = math.ceil((-1 + math.sqrt(1 + 8 * x_target_min)) / 2)

y0 = y_target_min - 1 # If we already pass the y target after one second, it's impossible to hit
while True:
    y0 += 1
    # We have y = ty_0 - t(t - 1)/2
    # which ends up being the quadratic formula t^2 + t(-1 - 2y_0) + 2y = 0
    # and we can use the formula t = (-b +- sqrt(b^2 - 4ac)) / 2a
    # where a = 1, b = -1 - 2y_0, c = 2y_target
    quad_b = -1 - 2 * y0
    # Because we assume the y target zone coordinates are negative,
    # the projectile reaches y_target_max before y_target_min and the order in the range is reversed.
    target_y_intervals = []
    # y may cross the y target zone on both the left and right halves of the parabola, so check both.
    for side_of_parabola in [-1, 1]:
        lower_bound = math.ceil((-quad_b + side_of_parabola * math.sqrt(quad_b ** 2 - 8 * y_target_max)) / 2)
        upper_bound = math.floor((-quad_b + side_of_parabola * math.sqrt(quad_b ** 2 - 8 * y_target_min)) / 2)
        if lower_bound > 0 and upper_bound >= lower_bound: # ignore t < 0 and misses
            target_y_intervals.append((lower_bound, upper_bound))
    if not target_y_intervals:
        continue

    for x0 in range(x0_min, x_target_max + 1):
        # Same quadratic formula as above, but on a different axis.
        # However, we only subtract the discriminant because the right half of the parabola doesn't exist
        # due to drag; x just flatlines at the apex of the half-parabola.
        quad_b = -1 - 2 * x0
        t_x_first = math.ceil((-quad_b - math.sqrt(quad_b ** 2 - 8 * x_target_min)) / 2)
        try:
            t_x_last = math.floor((-quad_b - math.sqrt(quad_b ** 2 - 8 * x_target_max)) / 2)
            hit_target = (
                t_x_last >= t_x_first and
                any(y[0] <= t_x_last and y[1] >= t_x_first for y in target_y_intervals)
            )
        except ValueError:
            # Drag reduces v_x to 0 before we get "close" to x_target_max
            hit_target = any(y[1] >= t_x_first for y in target_y_intervals)

        if hit_target:
            apex = y0 * (y0 + 1) // 2
            if apex > highest_success_apex:
                highest_success_apex = apex
                print(f'New highest apex (part 1): {apex}')
            successful_initial_velocity_count += 1
            print(f'Success count (part 2): {successful_initial_velocity_count}; v_init = {(x0, y0)}')

# @TODO Figure out an ending condition
