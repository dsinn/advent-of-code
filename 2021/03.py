#!/usr/bin/env python3
f = open('03.txt', 'r')
line_count = 0
line = f.readline() # Assume the length of the first line equals the length of all the others
f.seek(0, 0)
int_length = len(line.rstrip())

ones_minus_zeroes = [0 for _ in range(int_length)]
numbers = []
for line in f.readlines():
    for i, digit in enumerate(list(line.rstrip())):
        ones_minus_zeroes[i] += 1 if digit == '1' else -1
    numbers.append(int(line.rstrip(), 2))

gamma = epsilon = 0
for i in range(int_length):
    bit_to_add = 1 << i
    if ones_minus_zeroes[~i + int_length] > 0:
        gamma += bit_to_add
    else:
        epsilon += bit_to_add

print(f'Part 1: {gamma * epsilon}')

def get_rating(numbers, initial_ones_minus_zeroes, do_keep_more_common_bit):
    remaining_numbers = numbers.copy()
    remaining_ones_minus_zeroes = initial_ones_minus_zeroes.copy()
    i = 0
    while len(remaining_numbers) > 1:
        new_remaining_numbers = []
        new_remaining_ones_minus_zeroes = [0 for _ in range(int_length)]
        for number in remaining_numbers:
            if (((number & (1 << (~i + int_length))) > 0) == (remaining_ones_minus_zeroes[i] >= 0)) == do_keep_more_common_bit:
                new_remaining_numbers.append(number)
                for j in range(int_length):
                    new_remaining_ones_minus_zeroes[j] += 1 if (number & (1 << (~j + int_length))) > 0 else -1
        remaining_numbers = new_remaining_numbers
        remaining_ones_minus_zeroes = new_remaining_ones_minus_zeroes
        i += 1
    return remaining_numbers[0]

o2_rating = get_rating(numbers, ones_minus_zeroes, True)
co2_rating = get_rating(numbers, ones_minus_zeroes, False)

print(f'Part 2: {o2_rating * co2_rating}')
