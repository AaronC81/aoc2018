sequence = File.read(ARGV[0]).split.map { |x| x.to_i }

seen_before = []
result = sequence.cycle.inject(0) do |a, b|
    result = a + b
    break result if seen_before.include? result
    seen_before << result
    result
end
puts result