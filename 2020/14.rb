#!/usr/bin/env ruby

programs_data = File.read("#{__dir__}/14.txt").split(/(?=mask = )/)

def execute(programs_data, process_mask_lambda, process_lines_lambda)
  memory = {}
  programs_data.each do |program_data|
    lines = program_data.split("\n")
    first_line = lines.shift

    raise ArgumentError.new "Unable to parse mask line: \"#{line}\"" unless /^mask = ([01X]{36})$/ =~ first_line
    mask_data = process_mask_lambda.call($1.split('').reverse)

    lines.each do |line|
      raise ArgumentError.new "Unable to parse memory line: \"#{line}\"" unless /^mem\[(\d+)\] = (\d+)$/ =~ line
      process_lines_lambda.call(memory, mask_data, $1.to_i, $2.to_i)
    end
  end
  memory.values.inject(:+)
end

print 'Part 1: '
puts execute(
  programs_data,
  lambda { |mask_characters|
    and_mask = 0
    or_mask = 0

    mask_characters.each_with_index do |c, i|
      case c
      when '1'
        or_mask |= (1 << i)
      when '0'
        and_mask |= (1 << i)
      end
    end

    and_mask = ~and_mask
    {and_mask: and_mask, or_mask: or_mask}
  },
  lambda { |memory, mask_data, address, value|
    memory[address] = value & mask_data[:and_mask] | mask_data[:or_mask]
  }
)

print 'Part 2: '
puts execute(
  programs_data,
  lambda { |mask_characters|
    floating_bits = []
    mask_characters.each_with_index do |c, i|
      case c
      when '1'
        or_mask |= (1 << i)
      when 'X'
        floating_bits << i
      end
    end
    floating_bits
  },
  lambda { |memory, mask_data, address, value|
    base_address = address

    # Iterate through the power set of the floating bits
    (0 ... (1 << mask_data.count)).each do |bits_enabled|
      address = base_address

      mask_data.each_with_index do |floating_bit, i|
        if bits_enabled & (1 << i) === 0
          address &= ~(1 << floating_bit) # Set floating bit to 1
        else
          address |= 1 << floating_bit # Set floating bit to 1
        end
        memory[address] = value
      end
    end
  }
)
