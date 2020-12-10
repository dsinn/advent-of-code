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

combinations = [1, 1, 2] # f(n) = number of binary strings of length n that don't contain "000"
next_term = combinations.inject(:+)
for i in 3 .. one_chains.keys.max
  combinations << next_term
  next_term += combinations[i - 2] + combinations[i - 1]
end

puts "Part 1: #{differences[1] * differences[3]}"

print 'Part 2: '
puts one_chains.map { |k, v| combinations[k] ** v }.inject(:*)
