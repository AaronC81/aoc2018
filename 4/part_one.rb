# #value is :sleep for guard sleeping, :wake for waking up, and an integer
# for that guard starting shift.
Record = Struct.new('Record', :month, :day, :hour, :minute, :value)

SleepPeriod = Struct.new('SleepPeriod', :start_minute, :end_minute) do
    def sleep_length
        end_minute - start_minute 
    end

    def inspect
        "#{start_minute}-#{end_minute}"
    end
end

# Parses a record string into a Record instance.
def parse_record(string)
    captures = */^\[\d+-(\d+)-(\d+) (\d+):(\d+)\] (.+)$/.match(string).captures

    value = case captures[4]
    when 'falls asleep'
        :sleep
    when 'wakes up'
        :wake
    when /Guard #(\d+) begins shift/
        $1.to_i
    end

    actual_hour = captures[2].to_i.zero? ? 24 : 23
    Record.new(captures[0].to_i, captures[1].to_i, actual_hour, captures[3].to_i, value)
end

# Returns a sorting key suitable for sorting records chronologically.
def record_key(record)
    record.month * 1000000 + record.day * 10000 + record.hour * 100 + record.minute
end

records = File.read(ARGV[0]).lines.map { |l| parse_record(l) }

sorted_records = records.sort_by { |r| record_key(r) }
File.write('input_sorted.txt', sorted_records.join("\n"))
puts sorted_records

guard_sleep_patterns = {}
current_guard = nil
current_start = nil

sorted_records.each do |record|
    if record.value.is_a? Integer
        unless current_start.nil?
            guard_sleep_patterns[current_guard] ||= []
            guard_sleep_patterns[current_guard] << SleepPeriod.new(current_start, 60)
        end
        
        current_guard = record.value 
    end
    current_start = record.minute if record.value == :sleep

    if record.value == :wake
        guard_sleep_patterns[current_guard] ||= []
        guard_sleep_patterns[current_guard] << SleepPeriod.new(current_start, record.minute)

        current_start = nil
    end
end

p guard_sleep_patterns

guard_with_most_sleep = guard_sleep_patterns.max do |sleep_pattern|
    val = sleep_pattern[1].sum { |x| x.sleep_length }
    p [sleep_pattern[0], val]
    val
end[0]
puts "Guard ID: #{guard_with_most_sleep}"

periods = guard_sleep_patterns[guard_with_most_sleep]
times_asleep_during_minute = Hash.new(0)

periods.each do |period|
    (period.start_minute...period.end_minute).each do |m|
        times_asleep_during_minute[m] += 1
    end
end

p times_asleep_during_minute.sort_by { |k, v| v }
