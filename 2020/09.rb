#!/usr/bin/env ruby

numbers = []
sums = {} # sum -> index of the earlier operand in the latest pairings

part1 = nil
File.open("#{__dir__}/09.txt", 'r').each_line.map do |line|
  current_number = line.to_i

  # Update sums that use current_number as one of the operands
  for i in [0, numbers.count - 25].max ... numbers.count
    sum = numbers[i] + current_number
    sums[sum] = [sums[sum] || 0, i].max
  end

  numbers << current_number
  next if numbers.count <= 25

  if !sums.has_key? current_number || sums[current_number] < numbers.count - 26
    # The sum exists and the earlier operand is one of the previous 25
    part1 = current_number
    puts "Part 1: #{part1}"
    break
  end
end

for operands in 2 ... numbers.count
  sum = numbers[0, operands].inject(:+)
  for i in operands ... numbers.count
    if sum === part1
      range = numbers[i - operands, operands]
      puts "Part 2: #{range.min + range.max}"
      break
    end
    sum += numbers[i] - numbers[i - operands]
  end
end
