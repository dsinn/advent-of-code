#!/usr/bin/env ruby
mass_values = File.readlines("#{__dir__}/01.txt").map(&:to_i)

part1 = 0
mass_values.each { |mass| part1 += mass / 3 - 2 }
puts "Part 1: #{part1}"

part2 = 0
mass_values.each do |mass|
  fuel = mass
  # _Could_ cache fuel values here to potentially save some computation, but...meh
  while fuel > 0
    fuel = fuel / 3 - 2
    part2 += fuel if fuel > 0
  end
end
puts "Part 2: #{part2}"
