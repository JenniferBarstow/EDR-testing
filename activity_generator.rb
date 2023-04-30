# frozen_string_literal: true

require_relative 'activity_logger'
require 'json'
require 'time'
require 'socket'
require 'net/http'

class ActivityGenerator
  def initialize
    @logger = ActivityLogger.new
  end

  def start_process(executable_path, *args)
    process_name = File.basename(executable_path)
    command_line = "#{process_name} #{args.join(' ')}"
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
        process_name = process_name,
        command_line = command_line,
        error_message = e.message
      )
      return
    end
    @logger.log_process_activity(
      process_id = pid,
      process_name = process_name,
      command_line = command_line
    )
    write_log_to_file
  end

  def generate_file_creation(file_path)
    process_name = 'generate_file_creation'
    command_line = "#{process_name} #{file_path}"
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
        process_name = process_name,
        command_line = command_line,
        error_message = e.message
      )
      return
    else
      @logger.log_file_activity(file_path, 'create', process_name = process_name, command_line = command_line,
                                process_id = Process.pid)
    end
    write_log_to_file
  end

  def generate_file_modification(file_path, new_contents)
    process_name = 'generate_file_modification',
    command_line = "#{process_name} #{file_path} #{new_contents}"
    begin
      unless File.exist?(file_path)
        puts "File does not exist: #{file_path}"
        @logger.log_error_activity(
          process_name = process_name,
          command_line = command_line,
          error_message = "File does not exist: #{file_path}"
        )
        return
      end
      # Modify the file
      File.open(file_path, 'w') { |file| file.write(new_contents) }
    rescue StandardError => e
      puts "Failed to modify file: #{e.message}"
      @logger.log_error_activity(
        process_name = process_name,
        command_line = command_line,
        error_message = e.message
      )
      return
    else
      @logger.log_file_activity(
        file_path, 'modify',  process_name = process_name, command_line = command_line, Process.pid
      )
    end
    write_log_to_file
  end

  def generate_file_deletion(file_path)
    process_name = 'generate_file_deletion'
    command_line = "#{process_name} #{file_path}"
    begin
      # Delete the file
      File.delete(file_path)
    rescue StandardError => e
      puts "Failed to delete file: #{e.message}"
      @logger.log_error_activity(
        process_name = process_name,
        command_line = command_line,
        error_message = e.message
      )
      return
    else
      @logger.log_file_activity(
        file_path, 'delete', process_name, command_line, Process.pid
      )
    end
    write_log_to_file
  end

  def generate_network_activity(destination_address, destination_port, data)
    # Create a new TCP socket and establish a connection to the destination
    socket = TCPSocket.new(destination_address, destination_port)

    # Get the local IP address and port number
    local_address = Socket.ip_address_list.detect(&:ipv4_private?).ip_address
    local_port = socket.addr[1]

    # Send the data over the socket and receive the response
    socket.write(data)
    response = socket.read

    # Get the amount of data sent and the protocol used
    data_sent = data.bytesize
    protocol = 'TCP'

    # Get the process information
    process_name = "generate_network_activity"
    process_id = Process.pid
    command_line = "#{process_name} #{destination_address} #{destination_port} #{data}"

    # Log the network activity
    @logger.log_network_activity(
      destination_address = destination_address,
      destination_port = destination_port,
      source_address = local_address,
      source_port = local_port,
      amount_of_data = "#{data_sent} bytes",
      protocol_of_data = protocol,
      process_name = process_name,
      command_line = command_line,
      process_id = process_id
    )

    # Close the socket
    socket.close
  rescue StandardError => e
    puts "Failed to generate network activity: #{e.message}"
    @logger.log_error_activity(
      process_name = process_name,
      command_line = command_line,
      error_message = e.message
    )
  ensure
    write_log_to_file
  end


  def write_log_to_file
    @logger.write_log_to_file('activity_log.json')
  end

end