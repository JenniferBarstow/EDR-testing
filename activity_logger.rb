# frozen_string_literal: true

require 'date'
require 'json'

class ActivityLogger
  CACHE_TIME = 1800

  def initialize
    @log = []
  end

  def log_process_activity(process_id, process_name, command_line, status_type)
    log_entry = {
      type: 'process activity',
      timestamp: DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S'),
      username: ENV['USER'] || ENV['USERNAME'],
      process_name: process_name,
      command_line: command_line,
      process_id: process_id,
      status_type: status_type
    }
    @log << log_entry
  end

  def log_file_activity(
    file_path, activity_descriptor,
    process_name, command_line = '', process_id, status_type
  )
    log_entry = {
      type: 'file activity',
      timestamp: DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S'),
      file_path: file_path,
      file_type: File.extname(file_path),
      activity_descriptor: activity_descriptor,
      username: ENV['USER'] || ENV['USERNAME'],
      process_name: process_name,
      command_line: command_line,
      process_id: process_id,
      status_type: status_type
    }
    @log << log_entry
  end

  def log_network_activity(destination_address, destination_port, source_address, source_port,
                           amount_of_data_sent, protocol_name, process_name, command_line, process_id)
    log_entry = {
      type: 'network activity',
      timestamp: DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S'),
      destination_address: destination_address,
      destination_port: destination_port,
      source_address: source_address,
      source_port: source_port,
      amount_of_data_sent: amount_of_data_sent,
      protocol_name: protocol_name,
      username: ENV['USER'] || ENV['USERNAME'],
      process_name: process_name,
      command_line: command_line,
      process_id: process_id
    }
    @log << log_entry
  end

  def write_log_to_file(file_path)
    if File.exist?(file_path) && (Time.now - File.mtime(file_path)) < CACHE_TIME
      logs = JSON.parse(File.read(file_path))
    else
      logs = []
    end

    logs << @log

    File.open(file_path, 'w') do |file|
      file.write(JSON.pretty_generate(logs))
    end
  end
end
