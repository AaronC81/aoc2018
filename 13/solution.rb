require 'set'

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

# A cart which may move around a Grid.
class Cart
    attr_accessor :grid, :position, :direction, :next_intersection_action

    def initialize(grid, position, direction)
        @grid = grid
        @position = position
        @direction = direction

        @next_intersection_action = :turn_left
    end

    # A Hash keyed by [current direction, character] describing which direction
    # to change to after a move in a tick.
    def self.direction_lookup
        {
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

    # Simulate a tick of time by mutating this instance.
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

    # Scans over the grid and populates @carts with carts pointing in the right
    # directions.
    def create_all_carts
        carts = []

        grid.length.times do |top|
            grid.first.length.times do |left|
                next unless ['v', '^', '<', '>'].include?(self[left, top])

                direction = {
                    'v' => :down, '^' => :up, '<' => :left, '>' => :right
                }[self[left, top]]
                    
                carts << Cart.new(self, Point.new(left, top), direction) 
            end
        end

        carts
    end

    # Draws the map as a string, with carts as "O" characters.
    def draw(string)
        as_arr = string.split("\n")

        carts.each do |cart|
            as_arr[cart.position.top][cart.position.left] = "O"
        end

        as_arr.join("\n")
    end

    # Returns any single collision which has occured. Effectively, if this is
    # not null, there has been some collision. There could be more than one,
    # but this method will return only the first; to see them all, use
    # #collisions.
    # The collision is in the form [first cart, second cart].
    def collision
        carts.each do |cart_a|
            carts.each do |cart_b|                
                if cart_a.position == cart_b.position && cart_a != cart_b
                    return [cart_a, cart_b]
                end
            end
        end

        nil
    end

    # Returns any and all collisions as an array of arrays of the form
    # [[first cart, second cart], ...].
    def collisions
        results = []

        carts.each do |cart_a|
            carts.each do |cart_b|                
                if cart_a.position == cart_b.position && cart_a != cart_b
                    results << [cart_a, cart_b]
                end
            end
        end

        results
    end
end

# Prints the solution for part one.
def solve_part_one
    input = File.read(ARGV[0])

    grid = Grid.from_puzzle_input(input)
    grid.create_all_carts

    catch :crash do
        loop do
            grid.carts.each do |cart|
                cart.tick
                next unless grid.collision
                p grid.collision[0].position
                throw :crash
            end
        end
    end
end

# Prints the solution for part two.
def solve_part_two
    input = File.read(ARGV[0])

    grid = Grid.from_puzzle_input(input)
    grid.create_all_carts

    until grid.carts.one?
        # Deleting elements while iterating them really confuses Ruby by the
        # looks of things; keep track of elements we need to delete using a 
        # Set instead, ignoring them on future iterations then deleting at the
        # end
        scheduled_for_deletion = Set.new

        grid.carts.each do |cart|
            next if scheduled_for_deletion.include? cart

            cart.tick
            next unless grid.collision
            colls = grid.collisions

            colls.each do |coll|
                scheduled_for_deletion << coll[0] << coll[1]
            end
        end

        scheduled_for_deletion.each do |deleted_cart|
            grid.carts.delete(deleted_cart)
        end 

        # Re-sort the array following the deletions
        grid.carts.sort_by! { |c| c.position.top * 1000 + c.position.left }
    end

    p grid.carts.first.position
end
