Claim = Struct.new('Claim', :id, :from_left, :from_top, :width, :height)

# Given a claim as a string, returns an instance of Claim.
def parse_claim(str)
    Claim.new(*/^\#(\d+) \@ (\d+),(\d+): (\d+)x(\d+)$/.match(str).captures.map(&:to_i))
end

# This Hash is indexed by [left, top] and contains an array of claim IDs
# covering this space.
claims_covering = {}

# Add each claim's points to the Hash
lines = File.read(ARGV[0]).lines
number_of_claims = lines.length
lines.each do |x|
    claim = parse_claim(x)
    end_left = claim.from_left + claim.width
    end_top = claim.from_top + claim.height

    (claim.from_left...end_left).each do |l|
        (claim.from_top...end_top).each do |t|
            claims_covering[[l, t]] ||= []
            claims_covering[[l, t]] << claim.id
        end
    end
end

# Find overlapping values
overlapping = []
claims_covering.each do |_, v|
    if v.length > 1
        overlapping.push(*v)
    end
end

puts ((1...number_of_claims).to_a - overlapping).first
