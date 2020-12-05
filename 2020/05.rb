#!/usr/bin/env ruby
require 'set'

seats = SortedSet.new
max = 0 # Set doesn't have a `.last`, oof
File.open('05.txt', 'r').each_line.each do |line|
  row = line[0..6].gsub(/[FB]/, 'F' => '0', 'B' => '1').to_i(2)
  column = line[7..-1].gsub(/[LR]/, 'L' => '0', 'R' => '1').to_i(2)

  seat = row * 8 + column
  seats << seat
  max = seat if max < seat
end

puts "Highest seat number: #{max}"

previous_seat = seats.first # Hack-ish since I can't start iterating on the second element of a Set
seats.each do |seat|
  puts "Your seat could be between seats #{previous_seat} and #{seat}." if seat - previous_seat > 1
  previous_seat = seat
end
