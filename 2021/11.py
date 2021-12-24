#!/usr/bin/env python3
from os.path import dirname

f = open(f'{dirname(__file__)}/11.txt', 'r')

energy_levels = [
    [int(raw_energy_level) for raw_energy_level in list(line.rstrip()]
    for line in f.readlines()
]

def increment_octopus_energy(energy_levels, y, x):
    if y < 0 or x < 0:
        return
    try:
        energy_levels[y][x]
    except IndexError:
        return

    energy_levels[y][x] += 1
    if energy_levels[y][x] == 10:
        increment_octopus_energy(energy_levels, y - 1, x - 1)
        increment_octopus_energy(energy_levels, y - 1, x + 0)
        increment_octopus_energy(energy_levels, y - 1, x + 1)
        increment_octopus_energy(energy_levels, y + 0, x - 1)
        increment_octopus_energy(energy_levels, y + 0, x + 1)
        increment_octopus_energy(energy_levels, y + 1, x - 1)
        increment_octopus_energy(energy_levels, y + 1, x + 0)
        increment_octopus_energy(energy_levels, y + 1, x + 1)


flashes = 0
step = 1
while True:
    for i in range(len(energy_levels)):
        for j in range(len(energy_levels[i])):
            increment_octopus_energy(energy_levels, i, j)
    is_simultaneous_flash = True
    for i in range(len(energy_levels)):
        for j in range(len(energy_levels[i])):
            if energy_levels[i][j] > 9:
                flashes += 1
                energy_levels[i][j] = 0
            else:
                is_simultaneous_flash = False
    if step == 100:
        print(f'Part 1: {flashes}')
    if is_simultaneous_flash:
        print(f'Part 2: {step}')
        break
    step += 1
