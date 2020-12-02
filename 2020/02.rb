#!/usr/bin/env ruby
part1_count = 0
part2_count = 0
File.open('02.txt', 'r').each_line do |line|
  matches = /^(\d+)-(\d+) (.): (.+)$/.match(line)
  raise StandardError.new "Could not match #{line}" unless matches

  _, _, _, letter, password = matches.to_a
  number1 = matches[1].to_i
  number2 = matches[2].to_i

  letter_count = password.scan(letter).count
  part1_count += 1 if number1 <= letter_count && letter_count <= number2
  part2_count += 1 if (password[number1 - 1] == letter) != (password[number2 - 1] == letter)
end

puts "Part 1: #{part1_count}"
puts "Part 2: #{part2_count}"
