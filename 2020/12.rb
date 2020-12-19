#!/usr/bin/env ruby
require 'matrix'

$direction_vectors = [[1, 0], [0, -1], [-1, 0], [0, 1]].map! { |array| Matrix.columns [array] }
$character_map = {'E' => 0, 'S' => 1, 'W' => 2, 'N' => 3}

$rotation_matrices = [
  [[ 1,  0], [ 0,  1]],
  [[ 0,  1], [-1,  0]],
  [[-1,  0], [ 0, -1]],
  [[ 0, -1], [ 1,  0]]
].map! { |array| Matrix.rows array }

instructions = File.open("#{__dir__}/12.txt", 'r').each_line.map do |line|
  raise ArgumentError.new "Unable to parse \"#{line}\"" unless /^(.)(\d+)$/ =~ line
  [$1, $2.to_i]
end

# @TODO: Attempt to clean up any repetition between the two parts

def part1(instructions)
  ship = Matrix.columns [[0, 0]]
  direction_index = 0
  instructions.each do |args|
    instruction, value = args
    case instruction
    when 'L'
      direction_index -= value / 90
    when 'R'
      direction_index += value / 90
    when 'F'
      vector = $direction_vectors[direction_index % 4]
      ship += value * vector
    when 'E', 'S', 'N', 'W'
      vector = $direction_vectors[$character_map[instruction]]
      ship += value * vector
    else
      raise ArgumentError.new "Unknown instruction \"#{args.join ''}\""
    end
  end
  puts "(x, y) = #{ship.inspect}"
  puts "Part 1: #{ship[0, 0].abs + ship[1, 0].abs}"
end

def part2(instructions)
  wp = Matrix.columns [[10, 1]] # Waypoint relative to the ship
  ship = Matrix.columns [[0, 0]]

  instructions.each do |args|
    instruction, value = args

    case instruction
    when 'L', 'R'
      direction_index = value / 90
      direction_index *= -1 if instruction === 'L'
      wp = $rotation_matrices[direction_index % 4] * wp
    when 'F'
      ship += value * wp
    when 'E', 'S', 'N', 'W'
      vector = $direction_vectors[$character_map[instruction]]
      wp += value * vector
    else
      raise ArgumentError.new "Unknown instruction \"#{args.join ''}\""
    end
  end
  puts "(x, y) = #{ship.inspect}"
  puts "Part 2: #{ship[0, 0].abs + ship[1, 0].abs}"
end

part1(instructions)
part2(instructions)
