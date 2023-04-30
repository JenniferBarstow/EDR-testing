# frozen_string_literal: true
require 'json'
require 'date'
require_relative '../activity_generator'
require_relative '../activity_logger'

describe ActivityLogger do
  let(:logger) { ActivityLogger.new }
  let(:time) { DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S') }
  let(:user) { ENV['USER'] }

  describe '#log_process_start' do
    context 'process started' do
      it 'logs a process start event' do
        logger.log_process_activity('1234', 'redis-cli', 'redis-cli --help')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'process activity',
                                                              timestamp: time,
                                                              username: user,
                                                              process_name: 'redis-cli',
                                                              command_line: 'redis-cli --help',
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end

    context 'failure to start' do
      it 'raises an error' do
        logger.log_error_activity('reboot', 'reboot now', 'Failed to start process')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'error',
                                                              timestamp: time,
                                                              username: user,
                                                              process_name: 'reboot',
                                                              command_line: 'reboot now',
                                                              error_message: 'Failed to start process'
                                                            }
                                                          ])
      end
    end
  end

  describe '#log_file_activity' do
    context 'file creation' do
      it 'logs a file creation activity event' do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2021, 1, 1, 0, 0, 0))
        logger.log_file_activity('example.txt', 'create', 'generate_file_creation', 'generate_file_creation example.txt', '1234')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'file activity',
                                                              timestamp: '2021-01-01 00:00:00',
                                                              file_path: 'example.txt',
                                                              file_type: '.txt',
                                                              activity_descriptor: 'create',
                                                              username: user,
                                                              process_name: 'generate_file_creation',
                                                              command_line: 'generate_file_creation example.txt',
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end

    context 'file modification' do
      it 'logs a file modification activity event' do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2021, 1, 1, 0, 0, 0))
        logger.log_file_activity('example.txt','modify', 'generate_file_modification', 'generate_file_modification example.txt hello', '1234')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'file activity',
                                                              timestamp: '2021-01-01 00:00:00',
                                                              file_path: 'example.txt',
                                                              file_type: '.txt',
                                                              activity_descriptor: 'modify',
                                                              username: user,
                                                              process_name: 'generate_file_modification',
                                                              command_line: 'generate_file_modification example.txt hello',
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end

    context 'file deletion' do
      it 'logs a file deletion activity event' do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2021, 1, 1, 0, 0, 0))
        logger.log_file_activity('example.txt', 'delete', 'file deletion', 'generate_file_deletion example.txt' , '1234')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'file activity',
                                                              timestamp: '2021-01-01 00:00:00',
                                                              file_path: 'example.txt',
                                                              file_type: '.txt',
                                                              activity_descriptor: 'delete',
                                                              username: user,
                                                              process_name: 'file deletion',
                                                              command_line: 'generate_file_deletion example.txt',
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end

    describe '#log_network_activity' do
      it 'logs a network activity event' do
        command_line = 'generate_network_activity 192.168.1.1 80 data'
        allow(DateTime).to receive(:now).and_return(DateTime.new(2021, 1, 1, 0, 0, 0))
        logger.log_network_activity('192.168.1.1', '80', '192.168.1.2', '1234', '1024', 'TCP', 'chrome.exe', command_line, '1234')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'network_activity',
                                                              timestamp: '2021-01-01 00:00:00',
                                                              destination_address: '192.168.1.1',
                                                              destination_port: '80',
                                                              source_address: '192.168.1.2',
                                                              source_port: '1234',
                                                              amount_of_data_sent: '1024',
                                                              protocol_name: 'TCP',
                                                              username: ENV['USER'],
                                                              process_name: 'chrome.exe',
                                                              command_line: command_line,
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end
  end
end