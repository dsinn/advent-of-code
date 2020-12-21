#!/usr/bin/env ruby

class Tile
  TOP = 0
  RIGHT = 1
  BOTTOM = 2
  LEFT = 3

  def initialize(id, image)
    @id = id

    grid = image.split("\n").map { |line| line.split('') }

    @length = grid.size

    # Keep the order as left to right from the POV of the centre of the tile
    # so that all the subsequent tile matching works.
    @edges = [
      grid[0], # top edge
      grid.map { |row| row[-1] }, # right edge
      grid[-1].reverse, # bottom edge
      grid.map { |row| row[0] }.reverse # left edge
    ].map { |edge_array| edge_array.join('') }

    @image = grid
    @image.shift
    @image.pop
    @image.map! { |row| row[1 .. -2] }
  end

  def edges
    @edges
  end

  def id
    @id
  end

  def image
    @image
  end

  def flip_horizontal
    @edges = [
      @edges[TOP],
      @edges[LEFT],
      @edges[BOTTOM],
      @edges[RIGHT],
    ].map { |edge| edge.reverse }
    @image.map! { |row| row.reverse }
  end

  def flip_vertical
    @edges = [
      @edges[BOTTOM],
      @edges[RIGHT],
      @edges[TOP],
      @edges[LEFT]
    ].map { |edge| edge.reverse }
    @image.reverse!
  end

  def length
    @length
  end

  def rotate_ccw
    @edges << @edges.shift
    @image = @image.transpose.reverse
  end

  def rotate_cw
    @edges.unshift(@edges.pop)
    @image = @image.reverse.transpose
  end
end

def get_monster_regex_and_replacement_offsets(monster, full_image_length)
  lines = monster.split("\n")
  monster_length = lines.map(&:length).max
  # This assumes the image is square. We would need two different regexes with different join lengths otherwise.
  regex_join_length = full_image_length - monster_length + 1

  {
    regex: Regexp.new(
      '(?=' + # Use a look-ahead because they don't say the monsters can overlap, and it's not in the test case
          lines.map { |line|
            line.gsub(/ +/) { |m| "\\S{#{m.length}}" } + "\\S{#{monster_length - line.length}}"
          }.join(".{#{regex_join_length}}")
          .gsub('\\S{0}', '') # Just clean up the regex for neatness' sake
          .gsub('\\S{1}', '\\S') +
          ')',
      Regexp::MULTILINE
    ),
    offsets: lines.map.with_index { |line, i|
      line.enum_for(:scan, '#').map { Regexp.last_match.begin(0) + i * (full_image_length + 1) }
    }.inject(:+)
  }
end

# @TODO Abstract the normalizing logic into a helper/class or something
def normalize_edge(edge)
  [edge, edge.reverse].min
end

tiles = {} # id -> Tile object
File.read("#{__dir__}/20.txt").split(/\n{2,}/).map do |tile_input|
  id_line, image = tile_input.split("\n", 2)
  raise ArgumentError.new "Unable to parse \"#{id_line}\"" unless /^Tile (\d+):$/ =~ id_line
  id = $1.to_i
  tiles[id] = Tile.new id, image
end

edge_indices = {} # normalized edge -> (tile, edge position within tile)
tiles.each do |_id, tile|
  tile.edges.each_with_index do |edge, pos|
    edge_index = normalize_edge edge
    edge_indices[edge_index] = [] unless edge_indices.has_key? edge_index
    edge_indices[edge_index] << [tile, pos]
  end
end

tile_adjacencies = {} # tile ID -> adjacent tile IDs
edge_indices.each do |_k, v|
  if v.size === 2
    id1, id2 = v.first.first.id, v.last.first.id
    tile_adjacencies[id1] = [] unless tile_adjacencies.has_key? id1
    tile_adjacencies[id2] = [] unless tile_adjacencies.has_key? id2
    tile_adjacencies[id1] << id2
    tile_adjacencies[id2] << id1
  elsif v.size > 2
    raise StandardError.new 'The edges aren\'t unique, so this approach is flawed. :('
  end
end

corner_tiles = tile_adjacencies.select { |id, adjacent_ids| adjacent_ids.count === 2 }
puts "Corner tiles: #{corner_tiles.keys.inspect}"
puts "Part 1: #{corner_tiles.keys.inject(:*)}\n\n"

tile_grid = []
# Start with a random corner tile to place at the top-left and then build upon it;
# it's important to orient it so that adjacent tiles go to the right and bottom.
first_tile = tiles[corner_tiles.keys.first]
first_tile.rotate_cw while edge_indices[normalize_edge(first_tile.edges[Tile::RIGHT])].count === 1 ||
    edge_indices[normalize_edge(first_tile.edges[Tile::BOTTOM])].count === 1
tile_row = [first_tile]
j = 1
for _tile in 1 ... tiles.count
  # @TODO Cut down the number size of each case by storing only the adjacent tile and adjacent edge/position
  if j === 0 # Leftmost tile of the row
    # Match with the tile from the above row
    above_tile = tile_grid.last.first
    above_edge = above_tile.edges[Tile::BOTTOM] # Bottom edge of the above tile
    above_edge_index = normalize_edge above_edge
    tile_to_add, pos = edge_indices[above_edge_index].select { |edge_data| edge_data.first != above_tile }.first
    for rotation in 1 .. pos # 0 is the top edge
      tile_to_add.rotate_ccw
    end

    tile_to_add.flip_horizontal if above_edge === tile_to_add.edges[Tile::TOP]
  else
    # Match with the tile on the left
    left_tile = tile_row.last
    left_edge = left_tile.edges[Tile::RIGHT]
    left_edge_index = normalize_edge left_edge

    tile_to_add, pos = edge_indices[left_edge_index].reject { |edge_data| left_tile === edge_data.first}.first
    for rotation in pos ... 3
      tile_to_add.rotate_cw
    end

    tile_to_add.flip_vertical if left_edge === tile_to_add.edges[Tile::LEFT]
  end
  tile_row << tile_to_add
  j += 1

  if edge_indices[normalize_edge tile_to_add.edges[Tile::RIGHT]].count === 1
    # End of the row when there are no more tiles to match on the right
    j = 0
    tile_grid << tile_row
    tile_row = []
  end
end

tile_grid.each do |row|
  puts row.map { |tile| tile.id }.join(' ')
end
puts ''

image_length = tiles.first.last.length - 2 # Strip borders
full_image = tile_grid.map { |tile_row|
  full_image_row = []
  for i in 0 ... image_length
    full_image_row << tile_row.map { |tile| tile.image[i] }.inject(:+)
  end
  full_image_row
}.inject(:+)

monster = <<-'MONSTER'
                  #
#    ##    ##    ###
 #  #  #  #  #  #
MONSTER
puts 'Sea monster:'
puts "#{monster}\n"

full_image_length = full_image.first.length
# tbh "monster regex" has a double meaning and I like it
monster_regex, monster_segment_offsets = get_monster_regex_and_replacement_offsets(monster, full_image_length).values
puts "The O's will appear at the offets: #{monster_segment_offsets.inspect}"
puts "Monster regex: #{monster_regex}\n\n"

best_match_count = Float::INFINITY
best_match_string = ''

# There are only 8 distinct variations of the image when applying the transformations;
# Horizontal flips are unnecessary if you're doing vertical flips at every rotation.
for flip in 1 .. 2
  for rotation in 1 .. 4
    s = full_image.map { |row| row.join('') }.join("\n")
    monster_starts = s.enum_for(:scan, monster_regex).map { Regexp.last_match.begin(0) }
    monster_starts.each do |monster_start|
      monster_segment_offsets.each do |offset|
        s[monster_start + offset] = 'O'
      end
    end
    match_count = s.scan('#').count
    puts "Found #{monster_starts.count} sea monster(s) for #{match_count} rough waters."
    if match_count < best_match_count
      puts "This beats the previous best of #{best_match_count} rough waters!" if best_match_count != Float::INFINITY
      best_match_count = match_count
      best_match_string = s
    end

    full_image = full_image.transpose.reverse
  end
  full_image.reverse!
end
puts "\n"

puts "#{best_match_string}\n\n"
puts "Part 2: #{best_match_string.scan('#').count}"
