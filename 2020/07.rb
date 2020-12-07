#!/usr/bin/env ruby
require 'rgl/adjacency'
require 'rgl/path'

dg = RGL::DirectedAdjacencyGraph.new
weights = {}

File.open("#{__dir__}/07.txt", 'r').each_line.each do |line|
  raise StandardError.new("Unable to parse: #{line}") unless /^(.+?) bags? contain ([^\.]+)\.$/ =~ line
  parent_colour = $1

  $2.scan(/(\d+) ([^,]+) bags?/).each do |quantity, child_colour|
    dg.add_edge parent_colour, child_colour
    weights[[parent_colour, child_colour]] = quantity.to_i
  end
end

puts "Part 1: #{dg.reverse.bfs_iterator('shiny gold').count - 1}" # Don't count the shiny gold bag itself

def calc_bag_weight(dg, weights, colour)
  1 + dg.adjacent_vertices(colour).map { |adjacent_colour|
    weights[[colour, adjacent_colour]] * calc_bag_weight(dg, weights, adjacent_colour)
  }.inject(0, :+)
end

puts "Part 2: #{calc_bag_weight(dg, weights, 'shiny gold') - 1}" # Don't count the shiny gold bag itself
