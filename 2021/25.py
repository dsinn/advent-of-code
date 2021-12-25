#!/usr/bin/env python3
from os.path import dirname

f = open(f'{dirname(__file__)}/25.txt', 'r')

state = [list(line.rstrip()) for line in f.readlines()]

something_moved = True
steps = 0
while something_moved:
    something_moved = False

    # East
    new_state = [row.copy() for row in state]
    for i in range(len(state)):
        for j in range(len(state[i])):
            if state[i][j - 1] == '>' and state[i][j] == '.':
                new_state[i][j - 1] = '.'
                new_state[i][j] = '>'
                something_moved = True
    state = new_state

    # South
    new_state = [row.copy() for row in state]
    for i in range(len(state)):
        for j in range(len(state[i])):
            if state[i - 1][j] == 'v' and state[i][j] == '.':
                new_state[i - 1][j] = '.'
                new_state[i][j] = 'v'
                something_moved = True
    state = new_state

    steps += 1

print(steps)
