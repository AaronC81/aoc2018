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
