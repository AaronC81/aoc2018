require_relative "lib.rb"

# Create a point for each input line
points = File.read(ARGV[0]).split("\n")
    .map { |l| Point.new(*l.split(",").map(&:strip).map(&:to_i)) }

# Find smallest rect
rect = smallest_rect_for_points(points)

# Find the closest point to every cell in the rect
closest = {}
each_cell(rect) do |left, top|
    dists = points.map { |pt| [pt, (pt.left - left).abs + (pt.top - top).abs] }
    min_point = nil
    min_value = nil
    dists.each do |pt, d|
        if min_value.nil? || d < min_value
            min_value = d
            min_point = pt
        end
    end
    # Only include if there's no two points with the same minimum
    if dists.count { |pt, d| d == min_value } == 1
        closest[Point.new(left, top)] = min_point
    end
end

# Count references to each point
count = Hash.new(0)
closest.each do |this_point, closest_point|
    # Skip if we've said never to count this again
    next if count[closest_point] == -1
    
    count[closest_point] += 1

    # Don't count if on edge, and never count again
    if this_point.left == rect.top_left.left \
        || this_point.top == rect.top_left.top \
        || this_point.top == rect.bottom_left.top \
        || this_point.left == rect.bottom_left.left

        count[closest_point] = -1
    end
end

p count.max_by { |k, v| v }[1]
