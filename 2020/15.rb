#!/usr/bin/env ruby

starting_numbers = File.read("#{__dir__}/15.txt").split(',').map(&:to_i)

turn_index = {}
for i in 0 .. starting_numbers.count - 2
  turn_index[starting_numbers[i]] = i
end

number = starting_numbers.last
is_part1_needed = true

for turn in starting_numbers.count - 1 .. 30000000 - 2
  next_number = turn_index.has_key?(number) ? (turn - turn_index[number]) : 0
  turn_index[number] = turn
  number = next_number

  if is_part1_needed && turn === 2018
    is_part1_needed = false
    puts "Part 1: #{number}"
  end
end

puts "Part 2: #{number}"
