Node = Struct.new('Node', :child_nodes, :metadata_entries) do
    def size
        child_nodes.map(&:size).sum + metadata_entries.length + 2
    end
end

def read_node(numbers, start_location)
    number_of_child_nodes = numbers[start_location]
    number_of_metadata_entries = numbers[start_location + 1]

    child_nodes = []
    number_of_child_nodes.times do |n|
        child_nodes << read_node(
            numbers,
            start_location + 2 + child_nodes.map(&:size).sum
        )
    end

    metadata_entries = number_of_metadata_entries.times.map do |n|
        numbers[start_location + 2 + child_nodes.map(&:size).sum + n]
    end

    Node.new(child_nodes, metadata_entries)
end

def meta_sum(node)
    node.metadata_entries.sum + node.child_nodes.map { |x| meta_sum(x) }.sum
end

input_numbers = File.read(ARGV[0]).split.map(&:to_i)

puts meta_sum(read_node(input_numbers, 0))
