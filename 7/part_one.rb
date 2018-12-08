Step = Struct.new('Step', :name, :requirements, :required_by)

def find_order(graph)
    order = []

    # Insert the nodes to start at
    start = graph.select { |k, v| v.requirements.empty? }
    pending_nodes = start.map(&:first)

    # Until we've completed all steps...
    until pending_nodes.empty?
        catch :next do
            # Check if the requirements for each node are met
            pending_nodes.each do |node|
                if graph[node].requirements.all? { |req| order.include? req }
                    order << node
                    pending_nodes.delete(node)
                    pending_nodes.push(*graph[node].required_by)

                    # Re-sort the list, and restart this #each with the newly
                    # sorted list
                    pending_nodes.sort!
                    throw :next
                end
            end
        end
    end

    order.join
end

def create_graph(lines)
    graph = {}

    lines.each do |line|
        p line
        /^Step (.) must be finished before step (.) can begin\.$/ === line
        graph[$1] ||= Step.new($1, [], [])
        graph[$2] ||= Step.new($2, [], [])
        graph[$2].requirements << $1
        graph[$1].required_by << $2
    end

    graph
end

graph = create_graph(File.read(ARGV[0]).split("\n"))
puts find_order(graph)

