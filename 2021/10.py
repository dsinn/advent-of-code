#!/usr/bin/env python3
from os.path import dirname

f = open(f'{dirname(__file__)}/10.txt', 'r')

OPENING = {
    ')': '(',
    ']': '[',
    '}': '{',
    '>': '<'
}
SYNTAX_ERROR_POINTS = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137
}
COMPLETION_POINTS = {
    '(': 1,
    '[': 2,
    '{': 3,
    '<': 4
}

total_syntax_error_score = 0
completion_scores = []
for line in f.readlines():
    stack = []
    is_valid = True
    for i in range(len(line)):
        if line[i] in COMPLETION_POINTS:
            stack.append(line[i])
        elif line[i] in SYNTAX_ERROR_POINTS:
            if (not stack) or (stack.pop() != OPENING[line[i]]):
                total_syntax_error_score += SYNTAX_ERROR_POINTS[line[i]]
                is_valid = False
                break

    if not is_valid:
        continue

    completion_score = 0
    while stack:
        completion_score = completion_score * 5 + COMPLETION_POINTS[stack.pop()]
    completion_scores.append(completion_score)

print(f'Part 1: {total_syntax_error_score}')

completion_scores.sort()
print(f'Part 2: {completion_scores[len(completion_scores) // 2]}')
