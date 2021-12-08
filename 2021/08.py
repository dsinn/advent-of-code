#!/usr/bin/env python3
from collections import Counter, defaultdict
from functools import reduce
f = open('08.txt', 'r')

ORIGINAL_PATTERNS = {
    'abcefg': '0',
    'cf': '1',
    'acdeg': '2',
    'acdfg': '3',
    'bcdf': '4',
    'abdfg': '5',
    'abdefg': '6',
    'acf': '7',
    'abcdefg': '8',
    'abcdfg': '9'
}

entries = list(
    map(
        lambda line: tuple(map(lambda raw_side: raw_side.split(' '), line.rstrip().split(' | '))),
        f.readlines()
    )
)

print('Part 1: ', end = '')
print(
    sum(
        list(
            map(
                lambda entry: len(list(filter(lambda pattern: len(pattern) in [2, 4, 3, 7], entry[1]))),
                entries
            )
        )
    )
)

def decode_entry(entry):
    patterns, output = entry

    patterns_by_length = defaultdict(lambda: [])
    for pattern in patterns:
        patterns_by_length[len(pattern)].append(pattern)

    # Some of the so-called "easy digits" from Part 1
    pattern_one, pattern_seven, pattern_eight = list(map(lambda segments: patterns_by_length[segments][0], [2, 3, 7]))

    remapping = {} # scrambled segments ->  original segments

    # The difference between the segments of 7 and 1 is segment 'a'
    remapping[set(pattern_seven).difference(set(pattern_one)).pop()] = 'a'

    # Original segments b, e and f have a unique number of occurrences
    segments_by_frequency = Counter(list(''.join(patterns)))
    for segment, frequency in segments_by_frequency.items():
        match frequency:
            case 4:
                remapping[segment] = 'e'
                new_e = segment
            case 6:
                remapping[segment] = 'b'
            case 9:
                remapping[segment] = 'f'

    # Amongst the patterns with 6 segments...
    for i, six_segment_pattern in enumerate(patterns_by_length[6]):
        if new_e not in six_segment_pattern:
            # ...'9' is the only one that lacks original segment 'e'
            pattern_nine = six_segment_pattern
        else:
            if set(pattern_seven).issubset(set(six_segment_pattern)):
                # ...'0' is the only one that contains 7's segments plus original segment 'e'
                pattern_zero = six_segment_pattern
            else:
                # ...'6' doesn't fit the above criteria
                pattern_six = six_segment_pattern
    # '9' has original segment c but '6' doesn't
    remapping[set(pattern_nine).difference(set(pattern_six)).pop()] = 'c'
    # '0' is only missing original segment 'd'
    remapping[set(pattern_eight).difference(set(pattern_zero)).pop()] = 'd'
    # We now know what maps to original segments a-f, so by process of elimination the last segment is 'g'
    remapping[set(pattern_eight).difference(set(remapping.keys())).pop()] = 'g'

    return int(
        reduce(
            lambda output_string, digit_segments: output_string + ORIGINAL_PATTERNS[''.join(
                sorted(
                    list(
                        map(
                            lambda segment: remapping[segment],
                            list(digit_segments)
                        )
                    )
                )
            )],
            output,
            ''
        ),
        10
    )

print(f'Part 2: {sum(list(map(decode_entry, entries)))}')
