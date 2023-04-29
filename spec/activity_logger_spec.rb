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
        logger.log_process_activity('1234', 'redis-cli', '--help')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'process activity',
                                                              timestamp: time,
                                                              username: user,
                                                              process_name: 'redis-cli',
                                                              command_line: '--help',
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end

    context 'failure to start' do
      it 'raises an error' do
        logger.log_error_activity('bad.rb', '--help', 'Failed to start process')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'error',
                                                              timestamp: time,
                                                              username: user,
                                                              process_name: 'bad.rb',
                                                              command_line: '--help',
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
        logger.log_file_activity('example', 'txt', 'create', 'file creation', $PROGRAM_NAME, '1234')
        expect(logger.instance_variable_get(:@log)).to eq([
                                                            {
                                                              type: 'file activity',
                                                              timestamp: '2021-01-01 00:00:00',
                                                              file_path: 'example',
                                                              file_type: 'txt',
                                                              activity_descriptor: 'create',
                                                              username: user,
                                                              process_name: 'file creation',
                                                              command_line: $0,
                                                              process_id: '1234'
                                                            }
                                                          ])
      end
    end
  end
end