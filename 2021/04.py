#!/usr/bin/env python3
import re

class Board:
    def __init__(self, numbers):
        self.numbers = numbers
        self.width = len(numbers)

        # Count how many unmarked numbers there are on each row and column
        self.row_unmarked = [self.width for _ in range(self.width)]
        self.col_unmarked = self.row_unmarked.copy()

        self.position_map = {}
        self.unmarked_numbers = {}

        for i in range(self.width):
            for j in range(self.width):
                value = self.numbers[i][j]
                if value in self.position_map:
                    raise ValueError(f'"{value}" is a repeated number on the board.')
                self.position_map[value] = (i, j)
                self.unmarked_numbers[value] = True

    def mark_number(self, number):
        if number not in self.position_map:
            return
        self.unmarked_numbers.pop(number)
        row, col = self.position_map[number]

        self.row_unmarked[row] -= 1
        if self.row_unmarked[row] == 0:
            return True

        self.col_unmarked[col] -= 1
        if self.col_unmarked[col] == 0:
            return True

f = open('04.txt', 'r')
raw_boards = f.read().rstrip().split("\n\n")
called_numbers = list(map(lambda number_string: int(number_string), raw_boards.pop(0).split(',')))
boards = list(
    map(
        # lawl how do I do this nicely in Python
        lambda board_numbers: Board(board_numbers),
        list(
            map(
                lambda raw_board: list(
                    map(
                        lambda raw_row: list(
                            map(
                                lambda raw_board_entry: int(raw_board_entry),
                                re.split(' +', raw_row.strip()),
                            )
                        ),
                        raw_board.split("\n")
                    )
                ),
                raw_boards
            ),
        ),
    )
)

winning_products = []

for called_number in called_numbers:
    i = 0
    while i < len(boards):
        if boards[i].mark_number(called_number):
            winning_products.append(called_number * sum(boards[i].unmarked_numbers.keys()))
            boards.pop(i)
            i -= 1
        i += 1

print(f'Part 1: {winning_products[0]}')
print(f'Part 2: {winning_products[-1]}')
