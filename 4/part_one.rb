require 'date'
require 'active_support'
require 'active_support/core_ext/numeric'

BeginsShiftEntry = Struct.new(:date, :guard_id)
FallsAsleepEntry = Struct.new(:date)
WakesUpEntry = Struct.new(:date)

# Given one line from the input, returns an instance of any *Entry class.
def parse_entry(entry)
    # Extract the date and message
    raise 'invalid format' unless /^\[(.+)\] (.+)$/ === entry
    date = Time.parse($1)
    message = $2

    # Create and return an instance based on the message
    case message
    when 'falls asleep'
        FallsAsleepEntry.new(date)
    when 'wakes up'
        WakesUpEntry.new(date)
    when /Guard #(\d+) begins shift/
        BeginsShiftEntry.new(date, $1.to_i)
    end
end

# Read entries from file and sort on date
entries = File.read(ARGV[0])
    .split("\n")
    .map { |l| parse_entry(l) }
    .sort_by(&:date)

# Count the sleep time for each guard
minutes_of_sleep_per_guard = Hash.new
current_guard = nil
current_sleep_start = nil

entries.each do |entry|
    case entry
    when BeginsShiftEntry
        current_guard = entry.guard_id
        current_sleep_start = nil
    when FallsAsleepEntry
        current_sleep_start = entry.date
    when WakesUpEntry
        minutes_of_sleep_per_guard[current_guard] ||= Hash.new(0)
        (current_sleep_start.min...entry.date.min).each do |n|
            minutes_of_sleep_per_guard[current_guard][n] += 1
        end
        current_sleep_start = nil
    end
end

# Find the sleepiest guard and the minute they were asleep the most
sleepiest_guard = minutes_of_sleep_per_guard.max_by { |k, v| v.values.sum }[0]
sleepiest_guards_minute = minutes_of_sleep_per_guard[sleepiest_guard].max_by { |k, v| p k; p v }[0]

p sleepiest_guard * sleepiest_guards_minute
