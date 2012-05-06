require 'fog'
require 'find'

module Skyhook
	SKYHOOK_STORAGE_KEY = 'skyhook-storage'

	class Uploader
		
		def initialize(storage, bucket_name = 'skyhook', options = {})			
			
			@storage = storage
			
			begin
				bucket_info = @storage.get_bucket(bucket_name)
			rescue Exception => e
				@storage.put_bucket(bucket_name)
				@storage.put_bucket_versioning(bucket_name, 'Enabled')
			end
			
			@bucket = @storage.directories.get(bucket_name)
			
			@verbose = options[:verbose] == true
			@uploaded_total = 0.0
		end
		
		def upload(backup_config)
			backup_config.each do |backup|
				puts "Uploading directory #{backup['path']}" if @verbose
				upload_directory backup['path']
			end
			uploaded_mbs = @uploaded_total / 1024000.0
			puts "Uploaded #{uploaded_mbs.round(2)} MB"
		end
		
	private
		def upload_directory(directory, ignore_hidden = true)
			Find.find(directory) do |path|
				if FileTest.directory? path 
					if File.basename(path)[0] == ?. and ignore_hidden then
						Find.prune
					end
				else
					upload_file path
				end
			end
		end
		
		def upload_file(path)
			puts "Processing file #{path}" if @verbose
			key = "#{SKYHOOK_STORAGE_KEY}#{path}"
			existing_file = @bucket.files.get(key)
			if existing_file != nil and 
				existing_file.etag.eql? HashCalculator.calculate(path) then
				puts "Remote file already up to date, not uploading" if @verbose
			else
				cloud_file = @bucket.files.create(
					:key    => key,
					:body   => File.open(path),
					:public => false
				) 
				@uploaded_total += File.size(path)
			end
		end
		
	end
end