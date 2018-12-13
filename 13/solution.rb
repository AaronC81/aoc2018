# A point on the grid, where the top-left is 0,0.
Point = Struct.new('Point', :left, :top) do
    def self.direction_deltas
        {
            right: [1, 0],
            left: [-1, 0],
            down: [0, 1],
            up: [0, -1]
        }
    end

    # Returns a new point moved one step in a particular direction
    def moved_in(direction)
        delta = Point.direction_deltas[direction]
        raise "invalid direction #{direction.inspect}" if delta.nil?

        Point.new(left + delta[0], top + delta[1])
    end

    # Returns the direction between this point and then the other point.
    def adjacent_direction(other_point)
        res = Point.direction_deltas.rassoc(
            [other_point.left - self.left, other_point.top - self.top]
        )
        raise "invalid points #{self.inspect} and #{other_point}" if res.nil?
        res[0]
    end

    def to_s
        "(L #{left}, T #{top})"
    end

    alias inspect to_s
end

class Cart
    attr_accessor :grid, :position, :direction, :next_intersection_action

    def initialize(grid, position, direction)
        @grid = grid
        @position = position
        @direction = direction

        @next_intersection_action = :turn_left
    end

    def self.direction_lookup
        lookup_table = {
            [:left,  '/']  => :down,
            [:up,    '/']  => :right,
            [:down,  '/']  => :left,
            [:right, '/']  => :up,
            [:left,  '\\'] => :up,
            [:up,    '\\'] => :left,
            [:down,  '\\'] => :right,
            [:right, '\\'] => :down,
        }
    end

    def tick
        # Make the movement
        self.position = position.moved_in(direction)

        # Change direction
        lookup_result = Cart.direction_lookup[[direction, grid[position]]]
        self.direction = lookup_result unless lookup_result.nil?

        # Handle intersections
        if grid[position] == '+'
            case next_intersection_action
            when :turn_left
                self.next_intersection_action = :straight
                self.direction = {
                    up: :left, left: :down, down: :right, right: :up
                }[self.direction]

            when :straight
                self.next_intersection_action = :turn_right

            when :turn_right
                self.next_intersection_action = :turn_left
                self.direction = {
                    up: :right, right: :down, down: :left, left: :up
                }[self.direction]
            end
        end
    end
end

# An input grid with many tracks.
class Grid
    attr_accessor :grid, :carts

    # Constructs a new input from a string representing this grid.
    def self.from_puzzle_input(grid_string)
        Grid.new(grid_string.split("\n").map { |row| row.chars })
    end

    def initialize(grid)
        @grid = grid
        @carts = create_all_carts
    end

    # Gets a point on the grid, indexed by (left, top).
    def [](*args)
        if args[0].is_a? Point
            grid[args[0].top][args[0].left]
        elsif args[0].is_a?(Integer) && args[1].is_a?(Integer)
            grid[args[1]][args[0]]
        else
            raise
        end
    rescue
        raise "No point accessible with #{args.inspect}"
    end

    def create_all_carts
        carts = []

        grid.length.times do |top|
            grid.first.length.times do |left|
                #p "#{left},#{top} = #{self[left, top]} AND #{self[Point.new(left, top)]}"
                next unless ['v', '^', '<', '>'].include?(self[left, top])

                direction = {
                    'v' => :down, '^' => :up, '<' => :left, '>' => :right
                }[self[left, top]]
                    
                carts << Cart.new(self, Point.new(left, top), direction) 
            end
        end

        carts
    end

    def draw(string)
        #return tracks.map { |track| track.cart.position.to_s }.join("\n\n\n")

        as_arr = string.split("\n")

        carts.each do |cart|
            as_arr[cart.position.top][cart.position.left] = "O"
        end

        as_arr.join("\n")
    end

    def collision
        carts.each do |cart_a|
            carts.each do |cart_b|                
                if cart_a.position == cart_b.position && cart_a != cart_b
                    return cart_a.position
                end
            end
        end

        nil
    end
end

def solve_part_one
    input = File.read(ARGV[0])

    grid = Grid.from_puzzle_input(input)
    grid.create_all_carts

    ticks = 0

    catch :crash do
        loop do
            grid.carts.each do |cart|
                cart.tick
                next unless grid.collision
                p grid.collision
                throw :crash
            end
            ticks += 1
        end
    end
end

