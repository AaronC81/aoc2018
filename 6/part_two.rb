require_relative "lib.rb"

# Create a point for each input line
points = File.read(ARGV[0]).split("\n")
    .map { |l| Point.new(*l.split(",").map(&:strip).map(&:to_i)) }

# Find smallest rect
rect = smallest_rect_for_points(points)

# Create a 2D array of bools, true if total dist < 10000
# (Indexed by [left][top])
bool_map = []

left_offset = nil
top_offset = nil
each_cell(rect) do |left, top|
    left_offset = left if left_offset.nil?
    top_offset = top if top_offset.nil?

    bool_map[left - left_offset] ||= []

    dists = points.map { |pt| (pt.left - left).abs + (pt.top - top).abs }
    total_dist = dists.sum

    bool_map[left - left_offset][top - top_offset] = total_dist < 10000
end

# rotated but doesn't matter
str = ""
bool_map.each do |left|
    left.each do |top|
        str += top ? "X" : "."
    end
    str += "\n"
end

puts bool_map.flatten.flatten.count(true)
