# Calculates the number of characters which are different between two strings of
# the same length.
def distance(a, b)
    a.chars.zip(b.chars).map { |x, y| x == y ? 0 : 1 }.sum
end

sequence = File.read(ARGV[0]).split

sequence.each do |str_a|
    sequence.each do |str_b|        
        dist = distance str_a, str_b
        if dist == 1
            result = str_a.chars.zip(str_b.chars).map do |x, y|
                x == y ? x : nil
            end.reject(&:nil?).join

            puts result

            exit
        end
    end
end
