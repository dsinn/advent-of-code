#!/usr/bin/env python3
f = open('06.txt', 'r')

REPRODUCTIVE_PERIOD = 7
fish_by_modulo = [0 for _ in range(REPRODUCTIVE_PERIOD)]
newborn_by_modulo = fish_by_modulo.copy()
total_fish = 0
for timer in list(map(lambda timer: int(timer), f.read().rstrip().split(','))):
    fish_by_modulo[timer] += 1
    total_fish += 1

for day in range(0, 256):
    new_fish_reproduction_day = (day + 2) % REPRODUCTIVE_PERIOD
    day_modulo = day % REPRODUCTIVE_PERIOD
    birth_count = fish_by_modulo[day_modulo] - newborn_by_modulo[day_modulo]
    total_fish += birth_count
    fish_by_modulo[new_fish_reproduction_day] += birth_count
    newborn_by_modulo[day_modulo] = 0
    newborn_by_modulo[new_fish_reproduction_day] = birth_count
    if day == 17:
        print(f'Part 1: {total_fish}')

print(f'Part 2: {total_fish}')
