#!/usr/bin/env python3
from collections import defaultdict

f = open('12.txt', 'r')
graph = defaultdict(lambda: [])
for line in f.readlines():
    left, right = line.rstrip().split('-')
    graph[left].append(right)
    graph[right].append(left)

def find_paths(graph, paths, current_path, small_caves_visited, allow_double_visit):
    for node in graph[current_path[-1]]:
        if node == 'end':
            current_path.append('end')
            paths.append(current_path)
            continue
        if node == 'start':
            continue

        current_path_copy = current_path.copy()
        current_path_copy.append(node)

        if node.lower() == node:
            if node in small_caves_visited and not allow_double_visit:
                continue
            else:
                if node in small_caves_visited:
                    find_paths(graph, paths, current_path_copy, small_caves_visited, False)
                else:
                    small_caves_visited_copy = small_caves_visited.copy()
                    small_caves_visited_copy[node] = True
                    find_paths(graph, paths, current_path_copy, small_caves_visited_copy, allow_double_visit)
        else:
            find_paths(graph, paths, current_path_copy, small_caves_visited, allow_double_visit)
    return paths

part1_paths = find_paths(graph, [], ['start'], {}, False)
print(f'Part 1: {len(part1_paths)}')
part2_paths = find_paths(graph, [], ['start'], {}, True)
print(f'Part 2: {len(part2_paths)}')
