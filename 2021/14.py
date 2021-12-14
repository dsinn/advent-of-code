#!/usr/bin/env python3
from collections import Counter, defaultdict
import re
f = open('14.txt', 'r')

template = f.readline().rstrip()

rules = dict(
    map(
        lambda line: tuple(re.search('^([A-Z]+) -> ([A-Z]+)$', line).groups()),
        f.read().strip().split("\n")
    )
)

letter_counter = defaultdict(lambda: 0)
letter_counter.update(Counter(template).most_common())

pair_counter = defaultdict(lambda: 0)
for i in range(0, len(template) - 1):
    pair_counter[template[i:i+2]] += 1

def most_common_minus_least_common(letter_counter):
    sorted_frequencies = sorted(list(letter_counter.values()))
    return sorted_frequencies[-1] - sorted_frequencies[0]

for part, steps in enumerate([10, 30]):
    for _ in range(steps):
        new_pair_counter = defaultdict(lambda: 0)
        for pair, frequency in pair_counter.items():
            new_letter = rules[pair]
            letter_counter[new_letter] += frequency
            new_pair_counter[f'{pair[0]}{new_letter}'] += frequency
            new_pair_counter[f'{new_letter}{pair[1]}'] += frequency
        pair_counter = new_pair_counter
    print(f'Part {part + 1}: {most_common_minus_least_common(letter_counter)}')
