#!/usr/bin/env ruby

public_keys = File.readlines("#{__dir__}/25.txt").map(&:to_i)

first_loop_size = 0
value = 1
until value === public_keys.first
  first_loop_size += 1
  value = value * 7 % 20201227
end
puts "Loop size for first public key: #{first_loop_size}"

subject_number = public_keys.last
value = subject_number
(1 ... first_loop_size).each { |_loop| value = value * subject_number % 20201227 }
puts "Encryption key: #{value}"
