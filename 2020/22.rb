#!/usr/bin/env ruby

original_deck1 = []
original_deck2 = []
current_deck = original_deck1
File.readlines("#{__dir__}/22.txt").each do |line|
  current_deck << $1.to_i if /\A(\d+)\Z/ =~ line
  current_deck = original_deck2 if line === "Player 2:\n"
end

deck1 = Marshal.load(Marshal.dump original_deck1)
deck2 = Marshal.load(Marshal.dump original_deck2)
until deck1.empty? || deck2.empty?
  card1 = deck1.shift
  card2 = deck2.shift
  winning_deck = card1 > card2 ? deck1 : deck2
  cards_to_add = [card1, card2].sort
  winning_deck << cards_to_add.last
  winning_deck << cards_to_add.first
end

def compute_deck_score(deck)
  deck.reverse.map.with_index { |card, i| card * (i + 1) }.inject(:+)
end

puts "Part 1: #{compute_deck_score winning_deck}"

def get_winning_player(deck1, deck2)
  previous_states = {}

  until deck1.empty? || deck2.empty?
    serialized_decks = [deck1, deck2].map(&:inspect).join('')
    return 1 if previous_states.has_key? serialized_decks

    previous_states[serialized_decks] = true

    card1 = deck1.shift
    card2 = deck2.shift

    winner = if card1 <= deck1.count && card2 <= deck2.count
      get_winning_player(deck1[0, card1], deck2[0, card2])
    else
      card1 > card2 ? 1 : 2
    end
    winning_deck = winner === 1 ? deck1 : deck2

    cards_to_add = [card1, card2]
    cards_to_add.reverse! unless winner === 1
    winning_deck << cards_to_add.first
    winning_deck << cards_to_add.last
  end
  return deck2.empty? ? 1 : 2
end

deck1 = Marshal.load(Marshal.dump original_deck1)
deck2 = Marshal.load(Marshal.dump original_deck2)
get_winning_player(deck1, deck2)
print 'Part 2: '
puts compute_deck_score([deck1, deck2].reject { |deck| deck.empty? }.first)
