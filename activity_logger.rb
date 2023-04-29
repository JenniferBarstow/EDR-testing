# frozen_string_literal: true

require 'date'
require 'json'

class ActivityLogger
  CACHE_TIME = 1800

  def initialize
    @log = []
  end

  def log_process_activity(process_id, process_name, command_line)
    log_entry = {
      type: 'process activity',
      timestamp: DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S'),
      username: ENV['USER'] || ENV['USERNAME'],
      process_name: process_name,
      command_line: command_line,
      process_id: process_id
    }
    @log << log_entry
  end

  def log_error_activity(process_name, command_line, error_message)
    log_entry = {
      type: 'error',
      timestamp: DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S'),
      username: ENV['USER'] || ENV['USERNAME'],
      process_name: process_name,
      command_line: command_line,
      error_message: error_message
    }
    @log << log_entry
  end

  def write_log_to_file(file_path)
    logs = if File.exist?(file_path) && (Time.now - File.mtime(file_path)) < CACHE_TIME
             # Read the contents of the file and parse the JSON into an array of logs
             JSON.parse(File.read(file_path))
           else
             # Create a new array for the logs
             []
           end

    # Append the new log to the array
    logs << @log

    # Write the updated array of logs to the file
    File.open(file_path, 'w') do |file|
      file.write(JSON.pretty_generate(logs))
    end
  end
end