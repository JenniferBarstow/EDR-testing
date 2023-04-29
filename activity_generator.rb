# frozen_string_literal: true

require_relative 'activity_logger'
require 'json'
require 'time'

class ActivityGenerator
  def initialize
    @logger = ActivityLogger.new
  end

  def start_process(executable_path, *args)
    begin
      pid = case RUBY_PLATFORM
            when /mswin|mingw|cygwin/
              # Windows
              Process.spawn("#{executable_path}.exe", *args)
            else
              # Mac and Linux
              Process.spawn(executable_path, *args)
            end
    rescue StandardError => e
      puts "Failed to start process: #{e.message}"
      @logger.log_error_activity(
        process_name = File.basename(executable_path),
        command_line = "#{executable_path} #{args.join(' ')}",
        error_message = e.message
      )
      return
    end
    @logger.log_process_activity(
      process_id = pid,
      process_name = File.basename(executable_path),
      command_line = "#{executable_path} #{args.join(' ')}"
    )
    write_log_to_file
  end

  def generate_file_creation(file_path)
    file_type = File.extname(file_path)
  
    begin
      case RUBY_PLATFORM
      when /mswin|mingw|cygwin/
        `type nul > "#{file_path}"` # Windows
      else
        `touch "#{file_path}"` # Mac and Linux
      end
    rescue StandardError => e
      puts "Failed to create file: #{e.message}"
      @logger.log_error_activity(
        process_name = 'file creation',
        command_line = $PROGRAM_NAME,
        error_message = e.message
      )
      return
    else
      @logger.log_file_activity(file_path, file_type, 'create', process_name = 'file creation', command_line = $PROGRAM_NAME,
                                process_id = Process.pid)
    end
    write_log_to_file
  end

  def write_log_to_file
    @logger.write_log_to_file('activity_log.json')
  end

end