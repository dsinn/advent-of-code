#!/usr/bin/env ruby

# nil -> floor
# 0 -> empty chair
# 1 -> occupied chair
$map_chars = {nil => '.', 0 => 'L', 1 => '#'}

$direction_vectors = [-1, 0, 1].product([-1, 0, 1]) # Don't judge
$direction_vectors.delete_at(4)

original_state = File.open("#{__dir__}/11.txt", 'r').each_line.map do |line|
  line.rstrip.chars.map { |c| c === 'L' ? 0 : nil }
end

def compute_end_state(state, chair_count_method, occupied_chair_tolerance)
  loop do
    has_changed = false
    new_state = Marshal.load(Marshal.dump(state))
    state.each_with_index do |row, i|
      row.each_with_index do |point, j|
        if point === 0 && Kernel.send(chair_count_method, state, i, j) === 0
          has_changed = true
          new_state[i][j] = 1
        elsif point === 1 && Kernel.send(chair_count_method, state, i, j) >= occupied_chair_tolerance
          has_changed = true
          new_state[i][j] = 0
        end
      end
    end
    state = new_state
    return state unless has_changed
  end
end

def count_occupied_adjacent_seats(state, y, x)
  $direction_vectors.map { |vector|
    i = y + vector[0]
    j = x + vector[1]
    next 0 unless (0 ... state.count) === i && (0 ... state[i].count) === j
    state[i][j] || 0
  }.inject(:+)
end

def count_occupied_visible_seats(state, y, x)
  $direction_vectors.map { |vector| visibly_occupied_seats_in_direction(state, y, x, vector[0], vector[1]) }.inject(:+)
end

def visibly_occupied_seats_in_direction(state, y, x, y_step, x_step)
  loop do
    y += y_step
    x += x_step
    return 0 unless (0...state.count) === y && (0...state[y].count) === x
    return state[y][x] unless state[y][x].nil?
  end
end

def count_occupied_seats(state)
  state.map { |row|
    row.map { |point| point || 0 }.inject(:+)
  }.inject(:+)
end

def draw_map(state)
  state.each do |row|
    puts row.map { |point| $map_chars[point] }.inject(:+)
  end
  puts ''
end

part1_state = compute_end_state(original_state, :count_occupied_adjacent_seats, 4)
puts "Part 1: #{count_occupied_seats part1_state}"
draw_map part1_state

part2_state = compute_end_state(original_state, :count_occupied_visible_seats, 5)
puts "Part 2: #{count_occupied_seats part2_state}"
draw_map part2_state
