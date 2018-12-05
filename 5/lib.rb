# Checks if two units will react.
def will_react?(a, b)
    /[a-z][A-Z]|[A-Z][a-z]/.match?(a + b) && a.upcase == b.upcase
end

# Reacts adjacent units in an array.
def react(input)
    completed = [] # a buffer of units which will not react
    future = input.clone # a buffer of units where there could be reactions

    until future.one? || future.empty?
        # If we can react the first two elements of future, do so, otherwise
        # move one unit to completed
        if will_react?(future[0], future[1])
            # Remove these two elements
            future.shift
            future.shift

            # This could now allow the last completed element to react, so
            # move it back into future
            future.unshift(completed.pop) unless completed.empty?
        else
            completed << future.shift
        end
    end

    # If there's one element left and it would react, perform the final reaction
    # Otherwise just move it over
    if future.one? && will_react?(future.first, completed.last)
        completed.pop
        future.unshift
    elsif future.one?
        completed.push(future.unshift)
    end

    completed
end

