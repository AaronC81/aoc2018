# Mutates the input array to remove an adjacent reaction, returning a boolean
# indicating whether a reaction took place.
def make_pass!(input)
    input.clone.each_cons(2).with_index do |(a, b), i|
        next unless /[a-z][A-Z]|[A-Z][a-z]/.match?(a + b) && a.upcase == b.upcase
        #p "removing #{a}#{b} (#{i})"
        input.delete_at(i)
        input.delete_at(i)
        return true
    end

    false
end

input = File.read(ARGV[0]).chars
while make_pass! input; end
puts input.length