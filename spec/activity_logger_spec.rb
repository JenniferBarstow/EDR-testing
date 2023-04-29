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
end