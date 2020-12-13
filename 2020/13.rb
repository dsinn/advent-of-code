#!/usr/bin/env ruby

input = File.open("#{__dir__}/13.txt", 'r').each_line.map(&:rstrip)

time = input[0].to_f
buses = input[1].scan(/\d+/).map(&:to_i)

best_bus = -1
best_time = Float::INFINITY
buses.each do |bus|
  next_bus_time = (time / bus).ceil * bus
  if next_bus_time < best_time
    best_time = next_bus_time
    best_bus = bus
  end
end
puts "Part 1: #{best_bus * (best_time - time.to_i)}"

def compute_multiplicative_inverse(remainder, divisor)
  # Euclidean algorithm
  d = divisor
  y = 0
  x = 1

  while remainder > 1
    q = remainder / d
    old_divisor = d

    d = remainder % d
    remainder = old_divisor

    old_y = y
    y = x - q * y
    x = old_y
  end

  x % divisor
end

bus_remainder_pairs = {}
total_product = 1
input[1].split(',').each_with_index do |bus, offset|
  next if bus === 'x'
  bus = bus.to_i

  # Add the congruent equation `x ≡ remainder (mod bus)`
  bus_remainder_pairs[bus] = -offset % bus
  total_product *= bus
end

# Assume the buses are coprime and use the Chinese remainder theorem 🤷‍♀️
t = 0
bus_remainder_pairs.each do |bus, remainder|
  p = total_product / bus
  t += remainder * compute_multiplicative_inverse(p, bus) * p
end

puts "Part 2: #{t % total_product}"
