#!/usr/bin/env ruby

groups_strings = File.read("#{__dir__}/06.txt").rstrip.split(/\n{2,}/)
part1 = 0
part2 = 0
groups_strings.each do |group_string|
  part1_tracker = {}
  part2_tracker = {}

  group_size = group_string.scan("\n").count + 1
  group_string.gsub(/\s/, '').split('').each do |char|
    part1_tracker[char] = 0 unless part1_tracker.has_key? char
    part1_tracker[char] += 1
    part2_tracker[char] = true if part1_tracker[char] === group_size
  end
  part1 += part1_tracker.size
  part2 += part2_tracker.size
end

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
