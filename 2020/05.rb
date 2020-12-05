#!/usr/bin/env ruby
require 'set'

min = Float::INFINITY
max = 0
seats = {} # Existence map
File.open('05.txt', 'r').each_line.each do |line|
  row = line[0..6].gsub(/[FB]/, 'F' => '0', 'B' => '1').to_i(2)
  column = line[7..-1].gsub(/[LR]/, 'L' => '0', 'R' => '1').to_i(2)

  seat = row * 8 + column
  seats[seat] = true

  min = seat if min > seat
  max = seat if max < seat
end

puts "Highest seat number: #{max}"

print 'Missing seats: '
puts (min + 1..max - 1).reject {|i| seats.has_key? i}.inspect
