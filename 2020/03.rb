#!/usr/bin/env ruby

trees = []
File.open("#{__dir__}/03.txt", 'r').each_line do |line|
  trees << line.rstrip.split('').map{|c| c == '#' ? 1 : 0}
end

part2 = [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].map { |steps|
  x_step, y_step = steps
  tree_count = 0
  x = 0
  (0...trees.length).step(y_step).each do |y|
    tree_count += trees[y][x % trees[y].count]
    x += x_step
  end
  puts "Right #{x_step}, down #{y_step} -> #{tree_count}"
  tree_count
}.inject(:*)

puts "Product: #{part2}"
