class Circle < Array
    def wrap_index(index)
        index % length
    end

    def wrap_index_including_end(index)
        index == length ? index : wrap_index(index)
    end
end

/(\d+) players; last marble is worth (\d+) points/ === File.read(ARGV[0])
players = $1.to_i
last_marble_points = $2.to_i #add * 100 to solve part 2

current_player = 0
player_scores = Hash.new(0) # index 0 is first player
marbles = Circle.new([0])
current_marble_index = 0

(1..last_marble_points).each do |i|
    if i % 23 == 0
        #puts "!_!_!_!_! INDEX UNDERFLOW !_!_!_!_!" if current_marble_index - 7 < 0
        deletion_index = marbles.wrap_index(current_marble_index - 7)
        score_increase = marbles[deletion_index] + i

        marbles.delete_at(deletion_index)

        player_scores[current_player] += score_increase

        #puts "Player #{current_player}'s score increased by #{score_increase} to #{player_scores[current_player]}"

        current_marble_index = deletion_index
    else
        insertion_index = marbles.wrap_index_including_end(marbles.one? ? 1 : current_marble_index + 2)
        marbles.insert(insertion_index, i)
        current_marble_index = insertion_index
    end

    puts i if i % 100000 == 0

    #puts marbles.map.with_index { |x, i| i == current_marble_index ? "(#{x})" : x }.join ", "

    current_player = (current_player + 1) % players
end

p player_scores

puts player_scores.values.max
