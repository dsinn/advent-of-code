#!/usr/bin/env ruby

input_rules, input_messages = File.read("#{__dir__}/19.txt").split(/\n{2,}/)

rules = {}
input_rules.split("\n").each do |line|
  raise ArgumentError.new "Unable to parse \"#{line}\"" unless line =~ /^(\d+): *(.+)$/
  rules[$1.to_i] = $2
end
messages = input_messages.split("\n")

def get_rule(rules, i)
  return $pattern_cache[i] if $pattern_cache.has_key? i

  rule = rules[i]
  #puts "#{i}: #{rule}"
  if rule =~ /^"([^"]+)"$/
    $pattern_cache[i] = $1
    return $1
  end

  or_rules = rule.split(/ *\| */)
  $pattern_cache[i] = '(' + or_rules.map { |operand|
    operand.split(/ +/).map { |rule_index| get_rule rules, rule_index.to_i }.inject(:+)
  }.join('|') + ')'
  $pattern_cache[i]
end

def execute(rules, messages)
  $pattern_cache = {}
  regex = Regexp.new("^(?:#{get_rule rules, 0})$")
  messages.count { |message| regex =~ message }
end

puts "Part 1: #{execute rules, messages}"

rules[8] = "\"(#{get_rule rules, 42})+\""
# They did hint that a formal grammar isn't necessary for the problem so 🤷‍♀️
rules[11] = "\"(" + (1..69).map { |oofs|
  "(#{get_rule rules, 42}){#{oofs}}(#{get_rule rules, 31}){#{oofs}}"
}.join('|') + ")\""
puts "Part 2: #{execute rules, messages}"
