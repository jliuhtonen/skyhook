require 'optparse'
require 'logger'

module Skyhook
	class Cli
		def initialize()
			@action = :nothing
			@options = {}
			user_conf_path = File.join(@@SKYHOOK_USER_HOME, 'config.yml')
			if File.exists? user_conf_path then
				@options[:config_file] = user_conf_path
			else 
				@options[:config_file] = @@DEFAULT_CONFIG
			end
			@args = nil
			logs_path = File.join(@@SKYHOOK_USER_HOME, 'logs')
			FileUtils::mkdir_p logs_path
			@log = Logger.new(File.join(logs_path, 'skyhook.log'), 'daily')
		end
	
		def run()
			parse_args!
			
		    logger = lambda do |level, msg|
				puts "#{level}: #{msg}" if @options[:verbose]
				case level
					when :fatal
						@log.fatal msg
					when :warn
						@log.warn msg
					when :error
						@log.error msg
					when :info
						@log.info msg
					else
						@log.debug msg
				end
			end
			
			begin
				config = YAML.load_file(@options[:config_file])
				logger.call(:info, "Loaded config from #{@options[:config_file]}")
			rescue Errno::ENOENT => e
				puts "Config file #{@options[:config_file]} not found."
				return
			end
			
			storage = AWStorageFactory.create(config)
			@options[:compress] = config['compress']
			@options[:multipart_chunk_size] = config['multipart_chunk_size']

			begin
				case @action
					when :recover
						downloader = Skyhook::Downloader.new(storage, config['bucket_name'])
                    	downloader.overwrite_confirmation = lambda do |message|
                        	puts "#{message} Overwrite [y/n/a]?"
                        	STDOUT.flush
                        	case gets.chomp.to_sym
                            	when :a
                                	return :all
                            	when :y
                                	return :yes
                            	else
                                	return :no  
                        	end
                    	end
						downloader.download(@options[:download_files])
					when :backup
						uploader = Skyhook::Uploader.new(storage, config['bucket_name'], @options, logger)
						#begin
							uploader.upload(config['backup'])
					#	rescue Exception => e
					#		puts e.message
					#	end	
					when :nothing
						puts @args
				end
			rescue Excon::Errors::SocketError => e
				puts "Error connecting to AWS"
			end	
		end
		
	private
		@@DEFAULT_CONFIG = File.join(File.dirname(__FILE__), '../config.yml')
		@@SKYHOOK_USER_HOME = File.expand_path '~/.skyhook/'
		
		def parse_args!()
			@args = OptionParser.new do |opts|
				opts.banner = "Usage: skyhook.rb [options]"
	
				opts.on("-r", "--recover path1,path2,path3", Array, "Recover backed up files or directories") do |r|
					@action = :recover
					@options[:download_files] = r
				end
		
				opts.on("-b", "--backup [CONFIGFILE]", "Make backups (optionally using a specific config, config.yml by default)") do |c|
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
