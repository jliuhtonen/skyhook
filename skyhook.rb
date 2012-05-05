require 'fog'
require 'find'

module Skyhook
	SKYHOOK_STORAGE_KEY = 'skyhook-storage'

	class Uploader
		attr_accessor :verbose
		
		def initialize(access_key_id, access_key_secret, bucket_name = 'skyhook', public = false)
			#connect to S3
			puts access_key_id
			puts access_key_secret
			
			@storage = Fog::Storage.new({
  				:provider                 => 'AWS',
  				:aws_access_key_id        => access_key_id,
  				:aws_secret_access_key    => access_key_secret
			})
			
			begin
				bucket_info = @storage.get_bucket(bucket_name)
			rescue Exception => e
				@storage.put_bucket(bucket_name) unless bucket_info
			end
			
			@bucket = @storage.directories.get(bucket_name)
			
			p @bucket
			@verbose = true
		end
		
		def upload(directories)
			directories.each do |d|
				puts "Uploading directory #{d}" if @verbose
				upload_directory d
			end
		end
		
	private
		def upload_directory(directory, ignore_hidden = true)
			current_directory = directory
			Find.find(directory) do |path|
				if FileTest.directory? path 
					if File.basename(path)[0] == ?. and ignore_hidden then
						Find.prune
					else
						current_directory = directory
					end
				else
					md5 = OpenSSL::Digest::MD5.hexdigest(File.read(path))
					puts "#{path} checksum is #{md5}" if @verbose
					puts "Uploading file #{path}" if @verbose
					key = "#{SKYHOOK_STORAGE_KEY}/#{path}"
					existing_file = @bucket.files.get(key)
					
					if existing_file != nil and existing_file.etag.eql? md5 then
						puts "Remote file not changed, not uploading"
					else
						cloud_file = @bucket.files.create(
 							:key    => key,
  							:body   => File.open(path),
  							:public => false
						) 
					end
				end
			end
		end
		
	end
end

if __FILE__ == $0 then
	config = YAML.load_file('./config.yaml')
	uploader = Skyhook::Uploader.new(config['aws_access_key_id'], config['aws_secrey_key_id'], config['bucket_name'])
	uploader.upload(['/Users/janne/Pictures'])
end