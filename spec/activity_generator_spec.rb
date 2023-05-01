require 'rspec'
require_relative '../activity_generator'
require_relative '../activity_logger'

RSpec.describe ActivityGenerator do
  let(:generator) { described_class.new }

  describe '#start_process' do
    let(:executable_path) { 'pwd' }
    let(:args) {''}

    it 'logs the process activity' do
      expect_any_instance_of(ActivityLogger).to receive(:log_process_activity)

      generator.start_process(executable_path, *args)
    end

    it 'writes the log to file' do
      expect_any_instance_of(ActivityGenerator).to receive(:write_log_to_file)

      generator.start_process(executable_path, *args)
    end
  end

  describe '#generate_file_creation' do
    let(:file_path) { 'test_file.txt' }

    it 'logs the file activity' do
      expect_any_instance_of(ActivityLogger).to receive(:log_file_activity)

      generator.generate_file_creation(file_path)
    end

    it 'writes the log to file' do
      expect_any_instance_of(ActivityGenerator).to receive(:write_log_to_file)

      generator.generate_file_creation(file_path)
    end
  end

  describe '#generate_file_modification' do
    let(:file_path) { 'test_file.txt' }
    let(:new_contents) { 'new contents' }
   
    before do
      `touch #{file_path}`
    end
   
    it 'logs the file activity' do
      expect_any_instance_of(ActivityLogger).to receive(:log_file_activity)

      generator.generate_file_modification(file_path, new_contents)
    end

    it 'writes the log to file' do
      expect_any_instance_of(ActivityGenerator).to receive(:write_log_to_file)

      generator.generate_file_modification(file_path, new_contents)
    end
  end

  describe '#generate_file_deletion' do
    let(:file_path) { 'test_file.txt' }

    before do
      `touch #{file_path}`
    end
   
    it 'logs the file activity' do
      expect_any_instance_of(ActivityLogger).to receive(:log_file_activity)
      generator.generate_file_deletion(file_path)
    end
  end

  describe '#write_log_to_file' do
    it 'writes the log to file' do
      expect_any_instance_of(ActivityLogger).to receive(:write_log_to_file).with('activity_log.json')

      generator.write_log_to_file
    end
  end
end
