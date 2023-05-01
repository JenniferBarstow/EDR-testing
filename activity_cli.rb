#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'activity_generator'
require_relative 'activity_logger'
require 'json'
require 'socket'
require 'time'
require 'net/http'

class ActivityCLI
  def initialize
    @generator = ActivityGenerator.new
  end

  def start_process(args)
    executable_path = args.shift
    @generator.start_process(executable_path, *args)
  end

  def generate_file_creation(args)
    file_path = args.shift
    @generator.generate_file_creation(file_path)
  end

  def generate_file_modification(args)
    file_path = args.shift
    new_contents = args.shift
    @generator.generate_file_modification(file_path, new_contents)
  end

  def generate_file_deletion(args)
    file_path = args.shift
    @generator.generate_file_deletion(file_path)
  end

  def generate_network_activity(args)
    destination_address = args.shift
    destination_port = args.shift
    data = args.shift
    @generator.generate_network_activity(destination_address, destination_port, data)
  end
end

# Command line interface
cli = ActivityCLI.new
command = ARGV.shift
case command
when 'start_process'
  cli.start_process(ARGV)
when 'generate_file_creation'
  cli.generate_file_creation(ARGV)
when 'generate_file_modification'
  cli.generate_file_modification(ARGV)
when 'generate_file_deletion'
  cli.generate_file_deletion(ARGV)
when 'generate_network_activity'
  cli.generate_network_activity(ARGV)
else
  puts 'Unknown command'
end
