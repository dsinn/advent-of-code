#!/usr/bin/env ruby
require 'set'

min = Float::INFINITY
max = 0
seats = {} # Existence map
File.open("#{__dir__}/05.txt", 'r').each_line.each do |line|
  seat = line.gsub(/[FBLR]/, 'F' => '0', 'B' => '1', 'L' => '0', 'R' => '1').to_i(2)
  seats[seat] = true

  min = seat if min > seat
  max = seat if max < seat
end

missing_seats = []
for i in 0..max
  if i < min
    print ' '
  elsif seats.has_key?(i)
    print '.'
  else
    print 'X'
    missing_seats << i
  end
  print ' ' if i % 4 === 3
  puts " #{(i - 7).to_s.rjust(3)}-#{i.to_s.rjust(3)}" if i % 8 === 7
end
puts ''

puts "Highest seat number: #{max}"
puts "Missing seats: #{missing_seats.inspect}"
