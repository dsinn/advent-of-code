#!/usr/bin/env ruby

joltages = File.open("#{__dir__}/10.txt", 'r').each_line.map do |line|
  line.to_i
end

joltages.sort!

differences = [nil, 0, 0, 1]
differences[joltages.first] += 1
one_chains = {} # How many times n consecutive one-steps occurred

consecutives_ones = joltages.first === 1 ? 1 : 0
for i in 1 ... joltages.count
  difference = joltages[i] - joltages[i - 1]
  differences[difference] += 1

  if difference === 1
    consecutives_ones += 1
  else
    one_chains[consecutives_ones] = 0 unless one_chains.has_key? consecutives_ones
    one_chains[consecutives_ones] += 1
    consecutives_ones = 0
  end
end
one_chains[consecutives_ones] += 1

puts joltages.inspect
puts one_chains.inspect
puts differences.inspect

puts "Part 1: #{differences[1] * differences[3]}"

# TODO: Figure out the general formula to deal with "one_chains" that are longer than 4
puts "Part 2: #{2 ** one_chains[2] * 4 ** one_chains[3] * 7 ** one_chains[4]}"
