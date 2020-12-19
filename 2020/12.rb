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

def execute(instructions, left:, right:, forward:, direction:)
  instructions.each do |args|
    instruction, value = args
    case instruction
    when 'L'
      left.call(value)
    when 'R'
      right.call(value)
    when 'F'
      forward.call(value)
    when 'E', 'S', 'W', 'N'
      vector = $direction_vectors[$character_map[instruction]]
      direction.call(value, vector)
    else
      raise ArgumentError.new "Unknown instruction \"#{args.join ''}\""
    end
  end
end

direction_index = 0
ship = Matrix.columns [[0, 0]]
execute(
  instructions,
  left: lambda { |value| direction_index -= value / 90 },
  right: lambda { |value| direction_index += value / 90 },
  forward: lambda { |value| ship += value * $direction_vectors[direction_index % 4] },
  direction: lambda { |value, vector| ship += value * vector }
)
puts "(x, y) = #{ship.inspect}"
puts "Part 1: #{ship[0, 0].abs + ship[1, 0].abs}"

ship = Matrix.columns [[0, 0]]
wp = Matrix.columns [[10, 1]] # Waypoint relative to the ship
execute(
  instructions,
  left: lambda { |value| wp = $rotation_matrices[(-value / 90) % 4] * wp },
  right: lambda { |value| wp = $rotation_matrices[(value / 90) % 4] * wp },
  forward: lambda { |value| ship += value * wp },
  direction: lambda { |value, vector| wp += value * vector }
)
puts "(x, y) = #{ship.inspect}"
puts "Part 2: #{ship[0, 0].abs + ship[1, 0].abs}"
