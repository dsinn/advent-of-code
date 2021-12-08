#!/usr/bin/env python3
WINDOW_SIZE = 3

singular_increase_count = 0
sliding_window_increase_count = 0

f = open('01.txt', 'r')

# Initialize the sliding window so that the main loop is simpler
previous_numbers = list(map(lambda x: int(x.rstrip()), [f.readline() for x in range(WINDOW_SIZE)]))

# ...with the trade-off being having to compensate for Part 1 here.
for i in range(1, len(previous_numbers)):
    if previous_numbers[i] > previous_numbers[i - 1]:
        singular_increase_count += 1

while True:
    line = f.readline()
    if not line:
        break

    number = int(line.rstrip())
    if number > previous_numbers[0]:
        sliding_window_increase_count += 1
    if number > previous_numbers[-1]:
        singular_increase_count += 1

    previous_numbers.pop(0)
    previous_numbers.append(number)

print(f'Part 1: {singular_increase_count}')
print(f'Part 2: {sliding_window_increase_count}')
