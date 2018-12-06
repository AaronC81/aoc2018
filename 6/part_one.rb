Point = Struct.new('Point', :left, :top)
Rect = Struct.new('Rect', :top_left, :top_right, :bottom_left, :bottom_right)

# Given a collection of points, returns a Rect which contains all of the points.
def smallest_rect_for_points(points)
    # Create an initial rect which covers only one point
    initial_point = points.first
    rect = Rect.new(
        Point.new(initial_point.top, initial_point.left),
        Point.new(initial_point.top, initial_point.left),
        Point.new(initial_point.top, initial_point.left),
        Point.new(initial_point.top, initial_point.left)
    )
    
    # Expand it so it fills every point
    points.each do |point|
        # Check left
        if point.left < rect.top_left.left
            rect.top_left.left = point.left
            rect.bottom_left.left = point.left
        end

        # Check right
        if point.left > rect.top_right.left
            rect.top_right.left = point.left
            rect.bottom_right.left = point.left
        end

        # Check top
        if point.top < rect.top_left.top
            rect.top_left.top = point.top
            rect.top_right.top = point.top
        end

        # Check bottom
        if point.top > rect.bottom_left.top
            rect.bottom_left.top = point.top
            rect.bottom_right.top = point.top
        end
    end

    rect
end

# Executes a block on each cell of a rect.
def each_cell(rect)
    (rect.top_left.left..rect.top_right.left).each do |left|
        (rect.top_left.top..rect.bottom_left.top).each do |top|
            yield left, top
        end
    end
end

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
count = {}
closest.each do |this_point, closest_point|
    next if count[closest_point] == -1
    count[closest_point] ||= 0
    count[closest_point] += 1

    # Don't count if on edge
    if this_point.left == rect.top_left.left \
        || this_point.top == rect.top_left.top \
        || this_point.top == rect.bottom_left.top \
        || this_point.left == rect.bottom_left.left

        count[closest_point] = -1
    end
end

p count.max_by { |k, v| v }[1]
