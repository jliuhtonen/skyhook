module Skyhook
	class Cli
		def initialize()
			@action = :nothing
			@options = {}
			@args = nil
		end
	
		def run()
			config = YAML.load_file('./config.yaml')
			parse_args!
	
			case @action
				when :recover
					puts "Should recover now"
				when :backup
					uploader = Skyhook::Uploader.new(config['aws_access_key_id'], config['aws_secrey_key_id'], config['bucket_name'], @options)
					uploader.upload(config['backup'])	
				else
					puts @args
			end	
		end
		
	private
		
		def parse_args!()
			@args = OptionParser.new do |opts|
				opts.banner = "Usage: skyhook.rb [options]"
	
				opts.on("-r", "--recover PATH", "Recover backed up file or directory") do |r|
					@action = :recover
				end
		
				opts.on("-b", "--backup [CONFIGFILE]", "Make backups") do |c|
					@action = :backup
					@options[:config_file] = c
				end
		
				opts.on("-v", "--[no-]verbose", "Verbose output") do |v|
					@options[:verbose] = v
				end
			end
			@args.parse!
		end
	end
end
