# homerwork_assignment

This Ruby programs allows you to generate different processes and types of activity and then adds them to a log. The program is separated into 3 main parts: `ActivityGenerator`, `ActivityLogger` and `ActivityCLI`.

**Generating Activity and Logs** 

`ActivityCLI`

The user interacts with the program from the command line, using the `ActivityCLI`. 

The ActivityCLI class is a command line interface that takes a command and arguments as input, and uses a `case` statement to determine which `ActivityGenerator`method to call. This gives you the ability to call given processes from the command line, using commands like the ones below.

```ruby
$ ruby activity_cli.rb start_process redis-cli --help
$ ruby activity_cli.rb generate_file_creation example.txt
$ ruby activity_cli.rb generate_file_modification example.txt hello, world
$ ruby activity_cli.rb generate_file_deletion example.txt
$ ruby activity_cli.rb generate_network_activity icanhazip.com 80 'some data to send along' 

```
To generate errors to view in logs
```ruby
$ ruby activity_cli.rb start_process `$process_you_dont_have_permissions_to` 
$ ruby activity_cli.rb generate_file_creation invalid_path/example.txt
$ ruby activity_cli.rb generate_file_creation `$existing_file_path` `$existing_content`
```

**Viewing the Logs**

The Activity Logs can be found in the `activity_log.json` file after the processes are run.

**Description of Generator and Logger**

`ActivityGenerator`

The  ActivityGenerator class  is a collection of methods that generate various types of activity (process, file, network) and logs them to a file. The methods include`start_process`, `generate_file_creation`, `generate_file_modification` `generate_file_deletion`, `generate_network_activity` and `write_log_to_file`. 

The `start_process` method takes an executable path and some arguments as input, and tries to spawn a new process.  If it succeeds, it logs a process activity and writes the log to a file with the status of 'success'. If it fails, it logs the activity with the status of 'failure'.

The `generate_file_creation` method takes a file path as input, and creates a new file at that path. If it succeeds, it logs a file activity and writes the log to a file, with the status_type of 'success'.  If it fails, it logs with a status_type of 'failure'.

The `generate_file_modification` method takes a file path and new contents as input, and modifies the file at that path. If it succeeds, it logs a file activity and writes the log to a file with the status_type of 'success'. If it fails, it logs with a status_type of 'failure'

The `generate_file_deletion` method takes a file path as input, and deletes the file at that path. If it succeeds, it logs a file activity and writes the log to a file with the status_type of 'success'. If it fails to delete the file, it logs with the status type of 'failure. 

The `generate_network_activity` method takes a destination address, destination port, and data as input, and creates a new TCP socket to send the data to the destination. It logs a network activity and writes the log to a file.

The `write_log_to_file` method calls the `ActivityLogger`  `write_log_to_file` method and writes the current log to a file named `activity_log.json`.

`ActivityLogger`

The ActivityLogger class is called by methods belonging to the `ActivityGenerator` class and logs various types of activities to a file for later analysis. The activities are timestamped and include information about the user, process, file, or network activity that was performed.

**Testing**

$ rspec spec

**Dependencies:**

Ruby
