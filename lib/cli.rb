require 'optparse'

module Skyhook
	class Cli
		def initialize()
			@action = :nothing
			@options = {}
			@options[:config_file] = @@DEFAULT_CONFIG
			@args = nil
		end
	
		def run()
			parse_args!
			
			begin
				config = YAML.load_file(@options[:config_file])
			rescue Errno::ENOENT => e
				puts "Config file #{@options[:config_file]} not found."
				return
			end
			
			storage = AWStorageFactory.create(config)
	
			case @action
				when :recover
					puts "Should recover now"
				when :backup
					uploader = Skyhook::Uploader.new(storage, config['bucket_name'], @options)
					uploader.upload(config['backup'])	
				when :nothing
					puts @args
			end	
		end
		
	private
		@@DEFAULT_CONFIG = File.join(File.dirname(__FILE__), '../config.yaml')
		
		def parse_args!()
			@args = OptionParser.new do |opts|
				opts.banner = "Usage: skyhook.rb [options]"
	
				opts.on("-r", "--recover PATH", "Recover backed up file or directory") do |r|
					@action = :recover
				end
		
				opts.on("-b", "--backup [CONFIGFILE]", "Make backups (optionally using a specific config, config.yaml by default)") do |c|
					@action = :backup
					@options[:config_file] = c if c
				end
		
				opts.on("-v", "--[no-]verbose", "Verbose output") do |v|
					@options[:verbose] = v
				end
			end
			@args.parse!
		end
	end
end
