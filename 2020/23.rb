#!/usr/bin/env ruby

circle = File.read("#{__dir__}/23.txt").rstrip.split('').map(&:to_i)

part1_linked_cups = circle.map.with_index { |cup, i| [circle[i - 1], cup] }.to_h
part2_linked_cups = Marshal.load(Marshal.dump part1_linked_cups)

def execute_crab_maneuvres(linked_cups, current, moves, print: false)
  for move in 1 .. moves do
    picked_up = []
    pickup_pointer = current
    3.times do
      pickup_pointer = linked_cups[pickup_pointer]
      picked_up << pickup_pointer
    end
    after_pickup = linked_cups[pickup_pointer]

    destination = current
    loop do
      destination = destination == 1 ? linked_cups.length : destination - 1
      break unless picked_up.include? destination
    end
    after_destination = linked_cups[destination]

    if print
      puts "-- move #{move} --"
      print "cups: (#{current})"
      print_pointer = current
      (linked_cups.length - 1).times do
        print_pointer = linked_cups[print_pointer]
        print " #{print_pointer}"
      end
      puts "\npick up: #{picked_up.keys.join(', ')}"
      puts "destination: #{destination}\n\n"
    end

    linked_cups[current] = after_pickup
    linked_cups[destination] = picked_up.first
    linked_cups[pickup_pointer] = after_destination
    current = after_pickup
  end
end

execute_crab_maneuvres part1_linked_cups, circle.first, 100
print 'Part 1: '
print_pointer = 1
(part1_linked_cups.length - 1).times do
  print_pointer = part1_linked_cups[print_pointer]
  print print_pointer
end
puts

for i in circle.length + 1 .. 1000000 do
  part2_linked_cups[i] = i + 1
end
part2_linked_cups[circle.last] = circle.length + 1
part2_linked_cups[1000000] = circle.first

execute_crab_maneuvres part2_linked_cups, circle.first, 10000000
cup_after_1 = part2_linked_cups[1]
puts "Part 2: #{cup_after_1 * part2_linked_cups[cup_after_1]}"
