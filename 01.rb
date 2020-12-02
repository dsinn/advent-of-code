filename = '01.txt'
raise StandardError.new "#{filename} does not exist in the current working directory." unless File.file? filename

numbers = []
File.open(filename, 'r').each_line do |line|
  numbers << line.to_i
end

target = 2020
cache = {} # Just for existence
numbers.each do |number|
  cache[number] = true
  diff = target - number

  if cache.has_key? diff
    puts number * diff
    break
  end
end

products = {} # Maps from sums of two numbers -> their product
numbers.each_with_index do |number, i|
  for j in 0..i - 1
    products[number + numbers[j]] = number * numbers[j]
  end
end
numbers.each do |number|
  diff = target - number
  if products.has_key? diff # TODO: Add extra condition to avoid picking an already used number
    puts products[diff] * number
    break
  end
end
