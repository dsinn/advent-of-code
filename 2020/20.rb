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

def normalize_edge(edge)
  [edge, edge.reverse].min
end

tiles = {} # id -> Tile object
File.read("#{__dir__}/20.txt").split(/\n{2,}/).map do |tile_input|
  id_line, image = tile_input.split("\n", 2)
  raise ArgumentError.new "Unable to parse \"#{id_line}\"" unless /^Tile (\d+):$/ =~ id_line
  id = $1.to_i
  tiles[id] = Tile.new(id, image)
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
    raise StandardError.new 'Your approach is flawed or there is a bug. :('
  end
end

corner_tiles = tile_adjacencies.select { |id, adjacent_ids| adjacent_ids.count === 2 }
puts "Corner tiles: #{corner_tiles.keys.inspect}"
puts "Part 1: #{corner_tiles.keys.inject(:*)}\n\n"

# @TODO omg Part 2 is such a mess 😵

used_tile_ids = {}
tile_grid = []
grid_length = (tiles.length ** 0.5).round # @TODO Don't assume it's always a square
for i in 0 ... grid_length
  tile_row = []
  for j in 0 ... grid_length
    if i === 0 && j === 0
      # Start with a random corner tile to place at the top-left and then build upon it;
      # it's important to orient it so that adjacent tiles go to the right and bottom.
      tile_to_add = tiles[corner_tiles.keys.first]
      tile_to_add.rotate_cw while edge_indices[normalize_edge(tile_to_add.edges[Tile::RIGHT])].count === 1 || edge_indices[normalize_edge(tile_to_add.edges[Tile::BOTTOM])].count === 1
      tile_row << tile_to_add
    elsif j === 0 # Leftmost tile of the row
      # Match with the tile from the above row
      above_tile = tile_grid.last.first
      above_edge = above_tile.edges[Tile::BOTTOM] # Bottom edge of the above tile
      above_edge_index = normalize_edge above_edge
      tile_to_add, pos = edge_indices[above_edge_index].select { |edge_data| edge_data.first.id != above_tile.id }.first
      for rotation in 1 .. pos # 0 is the top edge
        tile_to_add.rotate_ccw
      end

      tile_to_add.flip_horizontal if above_edge === tile_to_add.edges[Tile::TOP]
      tile_row << tile_to_add
    else
      # Match with the tile on the left
      left_tile = tile_row.last
      left_edge = left_tile.edges[Tile::RIGHT]
      left_edge_index = normalize_edge left_edge

      if i > 0
        above_tile = tile_grid.last[j]
        above_edge = above_tile.edges[Tile::BOTTOM] # Bottom edge of the above tile
        above_edge_index = normalize_edge above_edge
      else
        above_edge = nil
      end

      if above_edge
        # Find the one tile that can fit between the left and above tiles and hasn't been used
        tile_to_add = tiles[(tile_adjacencies[left_tile.id] & tile_adjacencies[above_tile.id]).reject { |tile_id| used_tile_ids.has_key? tile_id }.first]
        tile_to_add.rotate_cw until left_edge_index === normalize_edge(tile_to_add.edges[Tile::LEFT])
      else
        tile_to_add, pos = edge_indices[left_edge_index].reject { |edge_data| left_tile.id === edge_data.first.id}.first
        for rotation in pos ... 3
          tile_to_add.rotate_cw
        end
      end

      tile_to_add.flip_vertical if left_edge === tile_to_add.edges[Tile::LEFT]
      tile_to_add.flip_horizontal if above_edge === tile_to_add.edges[Tile::TOP]

      tile_row << tile_to_add
    end

    used_tile_ids[tile_to_add.id] = true
  end
  tile_grid << tile_row
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

# @TODO For fun: take a monster string and dynamically generate its regex and replacements 😏
line_break_length = full_image.first.length - 19 # Line length - monster length + 1 (for the \n)
monster_regex = Regexp.new( # tbh "monster regex" has a double meaning and I like it
  # Use a look-ahead because they don't tell you that the monsters can overlap, and it's not in the test case
  "(?=\\S{18}#\\S.{#{line_break_length}}#(?:\\S{4}##){3}#.{#{line_break_length}}\\S(?:#\\S\\S){6}\\S)",
  Regexp::MULTILINE
)

best_match_count = Float::INFINITY
best_match_string = ''

# There are only 8 distinct variations of the image when applying the transformations;
# Horizontal flips are unnecessary if you're doing vertical flips at every rotation.
for flip in 1 .. 2
  for rotation in 1 .. 4
    s = full_image.map { |row| row.join('') }.join("\n")
    monster_offsets = s.enum_for(:scan, monster_regex).map { Regexp.last_match.begin(0) }
    monster_offsets.each do |monster_offset|
      # This is ugly af
      offset = monster_offset
      s[offset + 18] = 'O'
      offset += full_image.first.length + 1
      s[offset] = 'O'
      s[offset + 5] = 'O'
      s[offset + 6] = 'O'
      s[offset + 11] = 'O'
      s[offset + 12] = 'O'
      s[offset + 17] = 'O'
      s[offset + 18] = 'O'
      s[offset + 19] = 'O'
      offset += full_image.first.length + 1
      s[offset + 1] = 'O'
      s[offset + 4] = 'O'
      s[offset + 7] = 'O'
      s[offset + 10] = 'O'
      s[offset + 13] = 'O'
      s[offset + 16] = 'O'
    end
    match_count = s.scan('#').count
    puts "Found #{monster_offsets.count} sea monster#{monster_offsets.count === 1 ? '' : 's'} for #{match_count} rough waters."
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
