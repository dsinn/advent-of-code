#!/usr/bin/env ruby
codes = File.read("#{__dir__}/02.txt").rstrip.split(',').map(&:to_i)

def execute(codes)
  codes = Marshal.load(Marshal.dump codes)
  pointer = 0
  loop do
    case codes[pointer]
    when 1
      codes[codes[pointer + 3]] = codes[codes[pointer + 1]] + codes[codes[pointer + 2]]
    when 2
      codes[codes[pointer + 3]] = codes[codes[pointer + 1]] * codes[codes[pointer + 2]]
    when 99
      break
    else
      raise ArgumentError.new("Unrecognized opcode #{codes[pointer]}")
    end
    pointer += 4
  end
  codes[0]
end

codes[1] = 12
codes[2] = 2
puts "Part 1: #{execute codes}"

done = false
for noun in 0 .. 99
  for verb in 0 .. 99
    codes[1] = noun
    codes[2] = verb
    if execute(codes) === 19690720
      puts "Part 2: #{noun * 100 + verb}"
      done = true
      break
    end
  end
  break if done
end
