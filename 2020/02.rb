#!/usr/bin/env ruby
part1_count = 0
part2_count = 0
File.open("#{__dir__}/02.txt", 'r').each_line do |line|
  matches = /^(?<number1>\d+)-(?<number2>\d+) (?<letter>.): (?<password>.+)$/.match(line)
  raise StandardError.new "Unable to parse \"#{line}\"" unless matches

  letter, password = matches['letter'], matches['password']
  upper_bound = matches['number2'].to_i # Part 1 only
  pos1 = matches['number1'].to_i - 1 # Part 1 & 2
  pos2 = upper_bound - 1 # Part 2 only

  letter_count = password.scan(letter).count
  part1_count += 1 if pos1 < letter_count && letter_count <= upper_bound
  part2_count += 1 if (password[pos1] == letter) != (password[pos2] == letter)
end

puts "Part 1: #{part1_count}"
puts "Part 2: #{part2_count}"
