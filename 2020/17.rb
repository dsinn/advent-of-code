#!/usr/bin/env ruby

$character_map = ['.', '#']

$neighbour_vectors_3d = [-1, 0, 1].product([-1, 0, 1], [-1, 0, 1])
$neighbour_vectors_3d.delete_at($neighbour_vectors_3d.count / 2) # [0, 0, 0]

$neighbour_vectors_4d = [-1, 0, 1].product([-1, 0, 1], [-1, 0, 1], [-1, 0, 1])
$neighbour_vectors_4d.delete_at($neighbour_vectors_4d.count / 2) # [0, 0, 0, 0]

def count_active_cubes(state)
  # @TODO: Use recursion, but figure out how to avoid double-counting.
  # return state.map { |_, value| count_active_cubes(value) }.inject(:+) if state.is_a? Hash
  # state
  count = 0
  state.each do |z, subspace_3d|
    subspace_3d.each do |w, subspace_2d|
      subspace_2d.each do |_x, subspace_1d|
        subspace_1d.each do |_y, cube|
          operand = cube
          operand *= 2 if z > 0
          operand *= 2 if w > 0
          count += operand
        end
      end
    end
  end
  count
end

def count_active_neighbours(state, in_4d, x, y, z, w = 0)
  map_result = if in_4d
    $neighbour_vectors_4d.map { |vector| get_state(state, x + vector[0], y + vector[1], z + vector[2], w + vector[3]) }
  else
    $neighbour_vectors_3d.map { |vector| get_state(state, x + vector[0], y + vector[1], z + vector[2]) }
  end
  map_result.inject(:+)
end

def draw_state(state)
  for w in -$w_max .. $w_max
    for z in -$z_max .. $z_max
      puts "z=#{z}, w=#{w}"
      for y in $y_min .. $y_max
        for x in $x_min .. $x_max
          print $character_map[get_state(state, x, y, z.abs, w.abs)]
        end
        puts ''
      end
      puts ''
    end
  end
  puts "=" * ($x_max - $x_min + 1) + "\n\n"
end

def get_state(state, x, y, z, w = 0)
  state.dig(z.abs, w.abs, x, y) || 0
end

def set_state(state, value, x, y, z, w = 0)
  state[z] = {} unless state.has_key? z
  state[z][w] = {} unless state[z].has_key? w
  state[z][w][x] = {} unless state[z][w].has_key? x
  state[z][w][x][y] = value
  return unless value

  $x_min = x if x < $x_min
  $x_max = x if x > $x_max
  $y_min = y if y < $y_min
  $y_max = y if y > $y_max
  $z_max = z if z > $z_max
  $w_max = w if w > $w_max
end

def execute(in_4d, cycles)
  $x_min = $x_max = $y_min = $y_max = $z_max = $w_max = 0
  state = {} # [z, w, x, y]

  File.readlines("#{__dir__}/17.txt").each_with_index do |line, y|
    line.split('').each_with_index do |c, x|
      set_state(state, 1, x, y, 0) if c === '#'
    end
  end

  draw_state state
  for cycle in 1 .. cycles
    new_state = Marshal.load(Marshal.dump state)
    x_min, x_max, y_min, y_max, z_max = [$x_min, $x_max, $y_min, $y_max, $z_max]
    w_max = in_4d ? $w_max : -1

    for x in x_min - 1 .. x_max + 1
      for y in y_min - 1 .. y_max + 1
        for z in 0 .. z_max + 1
          for w in 0 .. w_max + 1
            num_active_neighbours = count_active_neighbours(state, in_4d, x, y, z, w)

            if get_state(state, x, y, z, w) > 0
              set_state(new_state, (2 .. 3) === num_active_neighbours ? 1 : 0, x, y, z, w)
            else
              set_state(new_state, 1, x, y, z, w) if 3 === num_active_neighbours
            end
          end
        end
      end
    end
    state = new_state
    draw_state state
  end

  # @TODO
  # if in_4d
  #   # Multiply quadrant by 4, then subtract the double-counting of the axes and centre subspace.
  #   4 * count_active_cubes(state) - ? * count_active_cubes(state[0]) - ? * state.map { |w, substate| count_active_cubes(w === 0 ? substate : 0) }.inject(:+) + ? * count_active_cubes(state[0][0])
  # else
  #   2 * count_active_cubes(state) - count_active_cubes(state[0][0])
  # end
  count_active_cubes(state)
end

part1 = execute(false, 6)
part2 = execute(true, 6)

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
