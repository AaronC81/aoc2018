sequence = File.read(ARGV[0]).split

# Count the occurences of each letter in each string
counts = sequence.map do |str|
    str.chars.inject(Hash.new(0)) { |h, c| h[c] += 1; h }
end

# Find how many times there are two or three occurences
two_occurences = 0
three_occurences = 0

counts.each do |count|
    values = count.values
    two_occurences += 1 if values.include? 2
    three_occurences += 1 if values.include? 3
end

# Calculate checksum
checksum = two_occurences * three_occurences
puts checksum
