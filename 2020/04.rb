#!/usr/bin/env ruby

$regex_by_field = {
  byr: '19([2-9]\d)|200[0-2]',
  iyr: '20(?:1\d|20)',
  eyr: '20(?:2\d|30)',
  hgt: '1([5-8]\d|9[0-3])cm|(59|6\d|7[0-6])in',
  hcl: '#[0-9a-f]{6}',
  ecl: 'amb|blu|brn|gry|grn|hzl|oth',
  pid: '\d{9}',
}

existence_regex = Regexp.new($regex_by_field.keys.map { |field| "\\b#{field}:" }.join('|'))

value_regex = Regexp.new(
  $regex_by_field.to_a.map { |(key, value)| "\\b#{key}:(?:#{value})\\b" }.join('|')
)

passports = File.read("#{__dir__}/04.txt").split(/\n{2,}/)

def count_valid_passports_from_regexes(passports, regex)
  passports.count { |passport| passport.scan(regex).count === $regex_by_field.count }
end

puts "Part 1: #{count_valid_passports_from_regexes(passports, existence_regex)}"
puts "Part 2: #{count_valid_passports_from_regexes(passports, value_regex)}"
