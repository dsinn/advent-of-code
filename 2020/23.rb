#!/usr/bin/env ruby

circle = File.read("#{__dir__}/23.txt").rstrip.split('').map(&:to_i)

current_pos = 0
for move in 1 .. 100
  puts "-- move #{move} --"
  puts "cups: #{circle.inspect}"
  puts "current cup: #{circle[current_pos]}"
  picked_up = circle.slice!(current_pos + 1, 3)
  starting_cups_to_take = 3 - picked_up.count
  if starting_cups_to_take > 0
    current_pos -= starting_cups_to_take
    picked_up += circle.slice!(0, starting_cups_to_take)
  end
  puts "pick up: #{picked_up.inspect}"

  destination_pos = nil
  current_cup_label = circle[current_pos]
  if circle.min === current_cup_label
    destination_pos = circle.find_index circle.max
  else
    (current_cup_label - 1).downto(1) do |label|
      destination_pos = circle.find_index(label)
      break unless destination_pos.nil?
    end
  end

  puts "destination: #{circle[destination_pos]}\n\n"
  insertion_pos = (destination_pos + 1) % circle.length
  current_pos += 3 if insertion_pos <= current_pos
  circle.insert insertion_pos, *picked_up

  current_pos = (current_pos + 1) % circle.length
end

puts '-- final -- '
puts "cups: #{circle.inspect}\n\n"

label1_index = circle.find_index 1
puts "Part 1: #{circle[label1_index + 1 .. -1].join ''}#{circle[0 ... label1_index].join ''}"

# @TODO Part 2
