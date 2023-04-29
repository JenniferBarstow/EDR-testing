# frozen_string_literal: true

require 'json'
require 'date'
require 'net/http'
require 'socket'
require_relative '../activity_generator'
require_relative '../activity_logger'

describe ActivityGenerator do
  let(:generator) { ActivityGenerator.new }
  let(:username) { ENV['USER'] || ENV['USERNAME'] }
  let(:time) { DateTime.now.to_time.utc.strftime('%Y-%m-%d %H:%M:%S') }

  describe '#generate_process_start' do
    context 'success' do
      let(:executable_path) { 'test.exe' }
      let(:args) { ['--test', '--verbose'] }
      let(:pid) { 12_345 }

      before :each do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2021, 1, 1, 0, 0, 0).to_time.utc)
        allow(Process).to receive(:spawn).and_return(pid)
      end

      it 'logs a process start event' do
        expect { generator.start_process(executable_path, args) }
          .to change { generator.instance_variable_get(:@logger).instance_variable_get(:@log) }
          .to contain_exactly(
            {
              type: 'process activity',
              timestamp: time,
              username: username,
              process_name: 'test.exe',
              command_line: 'test.exe --test --verbose',
              process_id: pid
            }
          )
      end
    end

    context 'failures' do
      let(:executable_path) { 'nothing' }
      let(:args) { ['--test', '--verbose'] }
      let(:pid) { 12_345 }

      it 'logs an error message if the process fails to start' do
        allow(Process).to receive(:spawn).and_raise(StandardError.new('Failed to start process'))

        expect { generator.start_process(executable_path, args) }
          .to change { generator.instance_variable_get(:@logger).instance_variable_get(:@log) }
          .to contain_exactly(
            {
              type: 'error',
              timestamp: time,
              username: username,
              process_name: 'nothing',
              command_line: 'nothing --test --verbose',
              error_message: 'Failed to start process'

            }
          )
        expect do
          generator.start_process(executable_path,
                                  *args)
        end.to output("Failed to start process: Failed to start process\n").to_stdout
      end
    end
  end

  describe '#generate_file_creation' do
    it 'logs a file creation event' do
      expect { generator.generate_file_creation('test.txt',) }
        .to change { generator.instance_variable_get(:@logger).instance_variable_get(:@log) }
        .to contain_exactly(
          {
            type: 'file activity',
            timestamp: time,
            file_path: 'test.txt',
            file_type: '.txt',
            activity_descriptor: 'create',
            username: username,
            process_name: 'file creation',
            command_line: $0,
            process_id: Process.pid
          }
        )
    end
  end

  describe '#generate_file_modification' do
    xit 'logs a file modification event' do
      expect { generator.generate_file_modification('test.txt', 'hello, world') }
        .to change { generator.instance_variable_get(:@logger).instance_variable_get(:@log) }
        .to contain_exactly(
          {
            type: 'file activity',
            timestamp: time,
            file_path: 'test.txt',
            file_type: '.txt',
            activity_descriptor: 'modify',
            username: username,
            process_name: 'file modification',
            command_line: $0,
            process_id: Process.pid
            
          }
        )
    end
  end

  describe '#generate_file_deletion' do
    it 'logs a file deletion event' do
      expect { generator.generate_file_deletion('test.txt') }
        .to change { generator.instance_variable_get(:@logger).instance_variable_get(:@log) }
        .to contain_exactly(
          {
            type: 'file activity',
            timestamp: time,
            file_path: 'test.txt',
            file_type: '.txt',
            activity_descriptor: 'delete',
            username: username,
            process_name: 'file deletion',
            command_line: $0,
            process_id: Process.pid
          }
        )
    end
  end

  describe 'generate_network_activity' do
    let(:logger) {  generator.instance_variable_get(:@logger) }
    let(:file_path) { 'activity_log.json' }

    it 'generates a network connection for a POST request' do
      allow(logger).to receive(:log_network_activity)
      allow(logger).to receive(:write_log_to_file).with('activity_log.json')

      allow(Net::HTTP).to receive(:post_form).and_return('hello')

      destination_address = 'www.example.com'
      destination_port = 80

      generator.generate_network_activity(destination_address, destination_port, 'body: hi')
      expect(logger).to have_received(:log_network_activity)
      expect(logger).to have_received(:write_log_to_file)
    end
  end
end
