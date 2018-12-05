require_relative 'lib'

input = File.read(ARGV[0]).chars
puts react(input).length