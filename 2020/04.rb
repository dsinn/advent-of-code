#!/usr/bin/env ruby

existence_regexes = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'].map{ |field| Regexp.new("\\b#{field}:\\S") }

value_regexes = [
  /byr:(19([2-9]\d)|200[0-2])/,
  /iyr:20(1\d|20)/,
  /eyr:20(2\d|30)/,
  /hgt:(1([5-8]\d|9[0-3])cm|(59|6\d|7[0-6])in)/,
  /hcl:#[0-9a-f]{6}/,
  /ecl:(amb|blu|brn|gry|grn|hzl|oth)/,
  /pid:\d{9}/,
].map{ |regex| Regexp.new("\\b#{regex.source}\\b") }

passports = File.read('04.txt').split(/\n{2,}/)

def count_valid_passports_from_regexes(passports, regexes)
  valid_count = 0
  passports.each do |passport|
    is_valid = true
    regexes.each do |regex|
      break (is_valid = false) if (regex =~ passport).nil?
    end
    valid_count += 1 if is_valid
  end
  valid_count
end

puts "Part 1: #{count_valid_passports_from_regexes(passports, existence_regexes)}"
puts "Part 2: #{count_valid_passports_from_regexes(passports, value_regexes)}"
