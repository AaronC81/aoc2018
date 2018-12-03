Claim = Struct.new('Claim', :id, :from_left, :from_top, :width, :height)

# Given a claim as a string, returns an instance of Claim.
def parse_claim(str)
    Claim.new(*/^\#(\d+) \@ (\d+),(\d+): (\d+)x(\d+)$/.match(str).captures.map(&:to_i))
end

# This Hash is indexed by [left, top] and contains the number of claims
# covering this space.
claim_counter = Hash.new(0)

# Add each claim's points to the Hash
File.read(ARGV[0]).lines.each do |x|
    claim = parse_claim(x)
    end_left = claim.from_left + claim.width
    end_top = claim.from_top + claim.height

    (claim.from_left...end_left).each do |l|
        (claim.from_top...end_top).each do |t|
            claim_counter[[l, t]] += 1
        end
    end
end

# Find values >= 2 and print count
puts claim_counter.select { |k, v| v >= 2 }.length
