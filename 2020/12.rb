#!/usr/bin/env ruby

$direction_vectors = [[1, 0], [0, -1], [-1, 0], [0, 1]]
$character_map = {'E' => 0, 'S' => 1, 'W' => 2, 'N' => 3}

$rotation_matrices = [
  [[ 1,  0], [ 0,  1]],
  [[ 0,  1], [-1,  0]],
  [[-1,  0], [ 0, -1]],
  [[ 0, -1], [ 1,  0]]
]

instructions = File.open("#{__dir__}/12.txt", 'r').each_line.map do |line|
  raise ArgumentError.new "Unable to parse \"#{line}\"" unless /^(.)(\d+)$/ =~ line
  [$1, $2.to_i]
end

# @TODO:
# * Attempt to clean up any repetition between the two parts
# * Perform matrix calculations more neatly

def part1(instructions)
  ship = [0, 0]
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
      ship.map!.with_index { |pos, axis| pos + value * vector[axis] }
    else
      vector = $direction_vectors[$character_map[instruction]]
      ship.map!.with_index { |pos, axis| pos + value * vector[axis] }
    end
  end
  puts "[x, y] = #{ship.inspect}"
  puts "Part 1: #{ship[0].abs + ship[1].abs}"
end

def part2(instructions)
  wp = [10, 1] # Waypoint relative to the ship
  ship = [0, 0]

  instructions.each do |args|
    instruction, value = args

    case instruction
    when 'L', 'R'
      direction_index = value / 90
      direction_index *= -1 if instruction === 'L'
      matrix = $rotation_matrices[direction_index % 4]

      wp = [
        wp[0] * matrix[0][0] + wp[1] * matrix[0][1],
        wp[0] * matrix[1][0] + wp[1] * matrix[1][1]
      ]
    when 'F'
      ship[0] += value * wp[0]
      ship[1] += value * wp[1]
    else
      vector = $direction_vectors[$character_map[instruction]]
      wp[0] += value * vector[0]
      wp[1] += value * vector[1]
    end
  end
  puts "(x, y) = #{ship.inspect}"
  puts "Part 2: #{ship[0].abs + ship[1].abs}"
end

part1(instructions)
part2(instructions)
