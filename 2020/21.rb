#!/usr/bin/env ruby

ingredient_counts = {}
ingredients_by_line = []
allergen_lines = {}

File.readlines("#{__dir__}/21.txt").each_with_index do |line, i|
  raise ArgumentError.new "Unable to parse \"#{line}\"" unless /([a-z ]+) \(contains ([^\)]+)\)/ =~ line
  ingredients = $1.split(' ')
  ingredients_by_line << ingredients
  ingredients.each do |ingredient|
    ingredient_counts[ingredient] = 0 unless ingredient_counts.has_key? ingredient
    ingredient_counts[ingredient] += 1
  end

  allergens = $2.split(', ')
  allergens.each do |allergen|
    allergen_lines[allergen] = [] unless allergen_lines.has_key? allergen
    allergen_lines[allergen] << i
  end
end

all_bad_ingredients = {}
raw_allergen_map = {}

allergen_lines.each do |allergen, line_numbers|
  bad_ingredients = line_numbers.map { |line_number| ingredients_by_line[line_number] }.inject(:&)
  bad_ingredients_hash = bad_ingredients.product([true]).to_h
  raw_allergen_map[allergen] = bad_ingredients_hash
  all_bad_ingredients.merge! bad_ingredients_hash
end

print 'Part 1: '
puts ingredient_counts.keep_if { |ingredient, _count| !all_bad_ingredients.has_key? ingredient }.values.inject(:+)

final_allergen_map = {}
until raw_allergen_map.empty?
  solved_allergens = raw_allergen_map.select { |allergen, ingredients| ingredients.count === 1 }
  solved_allergens.each do |allergen, ingredients|
    solved_ingredient = ingredients.keys.first
    final_allergen_map[allergen] = solved_ingredient
    raw_allergen_map.delete allergen
    raw_allergen_map.each do |_allergen, ingredients2|
      ingredients2.delete solved_ingredient
    end
  end
end

puts "Part 2: #{final_allergen_map.sort.map(&:last).join(',')}"
