Point = Struct.new('Point', :pos_x, :pos_y, :vel_x, :vel_y) do
    def tick
        self.pos_x += vel_x
        self.pos_y += vel_y
    end
end

Rect = Struct.new('Rect', :negative_corner, :positive_corner) do
    def width
        positive_corner.pos_x - negative_corner.pos_x
    end

    def height
        positive_corner.pos_y - negative_corner.pos_y
    end

    def area
        width * height
    end
end

def parse_input_line(line)
    regex = /position=<\s*([\-\d]+),\s*([\-\d]+)> velocity=<\s*([\-\d]+),\s*([\-\d]+)>/

    raise unless regex === line
    Point.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
end

def smallest_rect_for_points(points)
    # Create an initial rect which covers only one point
    initial_point = points.first
    rect = Rect.new(
        Point.new(initial_point.pos_x, initial_point.pos_y, 0, 0),
        Point.new(initial_point.pos_x, initial_point.pos_y, 0, 0)
    )
    
    # Expand it so it fills every point
    points.each do |point|
        # Check right
        if point.pos_x > rect.positive_corner.pos_x
            rect.positive_corner.pos_x = point.pos_x
        end

        # Check left
        if point.pos_x < rect.negative_corner.pos_x
            rect.negative_corner.pos_x = point.pos_x
        end

        # Check top
        if point.pos_y > rect.positive_corner.pos_y
            rect.positive_corner.pos_y = point.pos_y
        end

        # Check top
        if point.pos_y < rect.negative_corner.pos_y
            rect.negative_corner.pos_y = point.pos_y
        end
    end

    rect
end


def draw_points(points, rect)
    top_left = Point.new(rect.negative_corner.pos_x, rect.positive_corner.pos_y)

    points_hash = {}
    points.each do |pt|
        points_hash[[pt.pos_x - top_left.pos_x, top_left.pos_y - pt.pos_y]] = pt
        #points_hash[[(top_left.pos_x - pt.pos_x).abs, (pt.pos_y - top_left.pos_y).abs]] = pt
    end
    p "--"
    str = ""
    (rect.height).times do |y|
        (rect.width).times do |x|
            str += points_hash.include?([x, y]) ? "#" : "."
        end
        str += "\n"
    end

    str.split("\n").reverse.join("\n")
end

seconds = 0
points = File.read(ARGV[0]).split("\n").map { |x| parse_input_line(x) }
loop do
    # TODO: Track minimum so no magic numbers
    rect = smallest_rect_for_points(points)
    area = rect.area

    unless area > 1000
        puts area
        puts "This could be a match, after #{seconds} seconds"
        puts draw_points(points, rect)
        wait = $stdin.gets
    end
    seconds += 1
    points.each(&:tick)
end
