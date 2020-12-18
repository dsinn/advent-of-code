#!/usr/bin/env ruby

def advent_eval(expr, operators)
  parenthesis_indices = expr.enum_for(:scan, /[\(\)]/).map { Regexp.last_match.begin(0) }
  unless parenthesis_indices.empty?
    left_parens_index = parenthesis_indices.shift
    level = 1
    parenthesis_indices.each do |i|
      case expr[i]
      when '('
        level += 1
      when ')'
        level -= 1
      end
      return advent_eval(
        expr[0 ... left_parens_index] + advent_eval(expr[left_parens_index + 1 ... i], operators).to_s + expr[i + 1 .. -1],
        operators
      ) if level === 0
    end
  end

  operators.reverse.each do |operator|
    operator_index = expr.rindex(operator)
    if operator_index
      left_side = advent_eval(expr[0...operator_index], operators)
      right_side = advent_eval(expr[operator_index + 1 .. -1], operators)
      return left_side.send(expr[operator_index], right_side)
    end
  end

  expr.to_i
end

lines = File.readlines("#{__dir__}/18.txt")

print 'Part 1: '
puts lines.map { |line| advent_eval(line, [/[\+\*]/]) }.inject(:+)

print 'Part 2: '
puts lines.map { |line| advent_eval(line, ['+', '*']) }.inject(:+)
