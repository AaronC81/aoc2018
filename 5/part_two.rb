require_relative 'lib'

input = File.read(ARGV[0]).chars
with_no_removal = react(input).length

results = {}

('a'..'z').to_a.each do |removal_char|
    input_with_removed_char = input.reject { |x| x.downcase == removal_char }
    results[removal_char] = react(input_with_removed_char).length
end

puts results.min_by { |k, v| v } [1]
