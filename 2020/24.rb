#!/usr/bin/env ruby

state = {} # (x, y) -> black?
x_max = y_max = -Float::INFINITY
x_min = y_min = Float::INFINITY
black_count = 0
vector_map = {
  'e' => [2, 0],
  'se' => [1, 1],
  'sw' => [-1, 1],
  'w' => [-2, 0],
  'nw' => [-1, -1],
  'ne' => [1, -1],
}
$vectors = vector_map.values

File.readlines("#{__dir__}/24.txt").each do |line|
  x = 0
  y = 0
  line.scan(/e|se|sw|w|nw|ne/).each do |direction|
    vector = vector_map[direction]
    x += vector[0]
    y += vector[1]
  end
  state[[x, y]] = !state[[x, y]]
  black_count += state[[x, y]] ? 1 : -1
  x_min = x if x < x_min
  x_max = x if x > x_max
  y_min = y if y < y_min
  y_max = y if y > y_max
end

print 'Part 1: '
puts "#{black_count}\n\n"

def count_adjacent_black_tiles(state, x, y)
  $vectors.count { |vector| state[[x + vector[0], y + vector[1]]] }
end

for day in 1 .. 100
  changes = {}
  for y in y_min - 1 .. y_max + 1
    # Even y rows use even-numbered x-values; odd y rows use odd-numbered x-values
    x_min_offset, x_max_offset = if y & 1 === 0
      [2 - (x_min & 1), 2 - (x_max & 1)]
    else
      [1 + (x_min & 1), 1 + (x_max & 1)]
    end
    (x_min - x_min_offset).step(x_max + x_max_offset, 2) do |x|
      adjacent_blacks = count_adjacent_black_tiles state, x, y
      if state[[x, y]]
        if adjacent_blacks === 0 || adjacent_blacks > 2
          changes[[x, y]] = false
          black_count -= 1
        end
      else
        if adjacent_blacks === 2
          changes[[x, y]] = true
          black_count += 1
          x_min = x if x < x_min
          x_max = x if x > x_max
          y_min = y if y < y_min
          y_max = y if y > y_max
        end
      end
    end
  end
  changes.each { |k, v| state[k] = v }
  puts "Day #{day}: #{black_count}"
end
