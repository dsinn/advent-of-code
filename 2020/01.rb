#!/usr/bin/env ruby
numbers = File.readlines("#{__dir__}/01.txt").map(&:to_i)

target = 2020
indices = Hash[(0..numbers.size).zip numbers].invert
numbers.each_with_index do |number, i|
  diff = target - number

  if indices.has_key?(diff) && indices[diff] != i # Also check we're not using the same expenditure twice
    puts "Part 1: #{number * diff}"
    break
  end
end

indices = {} # Maps from sum of two numbers -> indices of the operands used
numbers.each_with_index do |number, i|
  for j in 0..i - 1
    indices[number + numbers[j]] = [i, j]
  end
end
numbers.each do |number|
  diff = target - number
  if indices.has_key?(diff) && !indices[diff].include?(number) # Also check we're not using the same expenditure twice
    puts "Part 2: #{number * indices[diff].map{ |x| numbers[x] }.inject(:*)}"
    break
  end
end
