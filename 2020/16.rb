#!/usr/bin/env ruby
range_input, your_ticket_input, nearby_tickets_input = File.read("#{__dir__}/16.txt").rstrip.split(/\n+(?:your ticket|nearby tickets):\n+/)

departure_indices = []
categories = range_input.split("\n").map.with_index do |line, i|
  departure_indices << i if line.start_with? 'departure'
  line.scan(/(\d+)-(\d+)/).map { |matches| (matches[0].to_i .. matches[1].to_i) }
end

your_ticket = your_ticket_input.split(',').map(&:to_i)
nearby_tickets = nearby_tickets_input.split("\n").map { |line| line.split(',').map(&:to_i) }

part1 = 0
valid_tickets = nearby_tickets.filter do |ticket|
  is_valid_ticket = true
  ticket.each do |number|
    is_valid_number = false
    categories.each do |category|
      category.each do |range|
        if range === number
          is_valid_number = true
          break
        end
      end
    end

    unless is_valid_number
      part1 += number
      is_valid_ticket = false
    end
  end
  is_valid_ticket
end
puts "Part 1: #{part1}"

# [i][j] is true if the ith category can be the jth column
possible_columns = (1..categories.count).map do |i|
  columns = {}
  (0 ... categories.count).each { |i| columns[i] = true }
  columns
end

valid_tickets.each do |ticket|
  ticket.each_with_index do |number, j|
    possible_columns.each_with_index do |columns, i|
      if columns.has_key? j
        is_in_range = false
        categories[i].each do |range|
          if range === number
            is_in_range = true
            break
          end
        end
        columns.delete(j) unless is_in_range
      end
    end
  end
end

# Assume that there's always a row with exactly one possible column
category_positions = {}
for i in 0 ... categories.count
  possible_columns.each_with_index do |columns, j|
    if columns.size === 1
      column, _ = columns.first
      category_positions[j] = column
      possible_columns.each { |columns| columns.delete column }
      break
    end
  end
end

print 'Part 2: '
puts departure_indices.map { |departure_index| your_ticket[category_positions[departure_index]] }.inject(:*)
