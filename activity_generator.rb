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

  def os_type
    if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
      'Windows'
    else
      'Unix'
    end
  end

  def start_process(executable_path, *args)
    process_name = 'start_process'
    command_line = "#{process_name} #{executable_path} #{args.join(' ')}"
    status_type = ''
    pid = nil
    begin
      if os_type == 'Windows'
        pid = Process.spawn("#{executable_path}.exe", *args)
        Process.wait(pid)
        status_type = if $?.success?
                        'success'
                      else
                        'failure'
                      end
      else
        pid = Process.spawn(executable_path, *args)
        Process.wait(pid)
        status_type = if $?.success?
                        'success'
                      else
                        'failure'
                      end
      end
    rescue StandardError => e
      puts "Failed to start process: #{e.message}"
      return
    end
    @logger.log_process_activity(
      pid,
      process_name,
      command_line,
      status_type
    )
    write_log_to_file
  end

  def generate_file_creation(file_path)
    process_name = 'generate_file_creation'
    command_line = ''
    begin
      if os_type == 'Windows'
        command_line = "type nul > #{file_path}" # Windows
        pid = Process.spawn(command_line)
        Process.wait(pid)
      else
        command_line = "touch #{file_path}" # Mac and Linux
        system(command_line)
      end
      status_type = if File.exist?(file_path)
        'success'
      else
        'failure'
      end  
    rescue StandardError => e
      puts "Failed to create file: #{e.message}"
      return
    else
      @logger.log_file_activity(file_path, 'create', process_name, command_line, Process.pid, status_type)
    end
    write_log_to_file
  end

  def generate_file_modification(file_path, new_contents)
    process_name = 'generate_file_modification'
    previous_contents = File.read(file_path)

    command_line = "File.open('#{file_path}', 'w') { |file| file.write('#{new_contents}') }"

    File.open(file_path, 'w') { |file| file.write(new_contents) }
    new_contents = File.read(file_path)

    if previous_contents != new_contents
      status_type = 'success'
    else
      status_type = 'failure'
    end

    @logger.log_file_activity(
      file_path, 'modify', process_name, command_line, Process.pid, status_type
    )
    write_log_to_file
  end

  def generate_file_deletion(file_path)
    process_name = 'generate_file_deletion'
    status_type = 'none'
    command_line = "File.delete('#{file_path}')"

    File.delete(file_path)

    if File.exist?(file_path)
      status_type = 'failure'
    else
      status_type = 'success'
    end

    @logger.log_file_activity(
      file_path, 'delete', process_name, command_line, Process.pid, status_type
    )
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
    process_name = 'generate_network_activity'
    process_id = Process.pid
    command_line = "#{process_name} #{destination_address} #{destination_port} #{data}"

    # Log the network activity
    @logger.log_network_activity(
      destination_address,
      destination_port,
      local_address,
      local_port,
      "#{data_sent} bytes",
      protocol,
      process_name,
      command_line,
      process_id
    )

    # Close the socket
    socket.close
  rescue StandardError => e
    puts "Failed to generate network activity: #{e.message}"
  ensure
    write_log_to_file
  end

  def write_log_to_file
    @logger.write_log_to_file('activity_log.json')
  end
end
