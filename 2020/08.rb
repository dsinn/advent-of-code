#!/usr/bin/env ruby

class InfiniteLoopError < StandardError; end

class InstructionsExecutor
  def self.execute(instructions)
    @@accumulator = 0
    @@line = 0
    lines_executed = {}

    while @@line < instructions.count
      raise InfiniteLoopError.new @@accumulator if lines_executed.has_key? @@line
      lines_executed[@@line] = true
      self.send *instructions[@@line]
    end

    @@accumulator
  end

  def self.acc(int)
    @@accumulator += int
    @@line += 1
  end

  def self.nop(_int)
    @@line += 1
  end

  def self.jmp(int)
    @@line += int
  end
end

base_instructions = File.open("#{__dir__}/08.txt", 'r').each_line.map do |line|
  /^(nop|acc|jmp) ([-+]\d+)/ =~ line
  [$1, $2.to_i]
end

begin
  InstructionsExecutor.execute(base_instructions)
rescue InfiniteLoopError => e
  puts "Part 1: #{e.message}"
end

base_instructions.each_with_index do |instruction, i|
  next if instruction[0] == 'acc'
  new_instructions = Marshal.load(Marshal.dump(base_instructions))
  new_instructions[i][0] = instruction[0].gsub(/nop|jmp/, 'nop' => 'jmp', 'jmp' => 'nop')
  begin
    puts "Part 2: #{InstructionsExecutor.execute(new_instructions)}"
    break
  rescue InfiniteLoopError
  end
end
