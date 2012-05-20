require 'fog'
require 'find'
require 'zlib'
require 'tempfile'
require File.join(File.dirname(__FILE__), 'metadata.rb')

module Skyhook

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
			@compress = options[:compress] == true
			@multipart_chunk_size = options[:multipart_chunk_size]
			@uploaded_total = 0.0
		end
		
		def upload(backup_config)
			backup_config.each do |backup|
				puts "Uploading directory #{backup['path']}" if @verbose
				upload_directory(backup['path'], backup['excludes'])
			end
			uploaded_mbs = @uploaded_total / 1024000.0
			puts "Uploaded #{uploaded_mbs.round(2)} MB"
		end
		
	private
		def upload_directory(directory, excludes, ignore_hidden = true)
			begin
				Find.find(directory) do |path|
					excludes.each do |exclude|
							Find.prune if (FileTest.directory? path and path =~ /#{exclude}/) or File.basename(path) =~ /#{exclude}/
					end if excludes
			
					if FileTest.directory? path 
						if File.basename(path)[0] == ?. and ignore_hidden then
							Find.prune
						end
					else
						upload_file path
					end
				end
			rescue Errno::ENOENT => e
				raise ArgumentError, 'No such file or directory ' + directory
			end
		end
		
		def upload_file(path)
			puts "Processing file #{path}" if @verbose
			key = "#{SKYHOOK_STORAGE_KEY}#{path}"
			existing_file = @bucket.files.head(key)
			checksum = HashCalculator.calculate(path)
			
			upload_path = path
			existing_file_metadata = existing_file.metadata if existing_file
			
			remote_checksum = existing_file_metadata[Metadata::CHECKSUM] if existing_file_metadata
			
			if existing_file != nil and remote_checksum.eql? checksum then
				puts "Remote file already up to date, not uploading" if @verbose
			else
				begin
					if @compress then
						tmpfile = compress_file path
						upload_path = tmpfile.path
					end
					puts "Uploading from #{upload_path}"
					cloud_file = @bucket.files.create(
						:key    => key,
						:body   => File.open(upload_path),
						:public => false,
						:multipart_chunk_size => @multipart_chunk_size,
						:metadata => {
							Metadata::CHECKSUM => checksum,
							Metadata::COMPRESSED => @compress
						}
					) 
					@uploaded_total += File.size(upload_path)
				ensure
					tmpfile.unlink if tmpfile
				end
			end
		end
		
		def compress_file(path)
			begin
				tmpfile = Tempfile.new('skyhook')
				gz = Zlib::GzipWriter.open(tmpfile)
  				gz.write File.read(path)
  			ensure
  				gz.close
				tmpfile.flush
				tmpfile.close
			end
			tmpfile
		end
		
	end
end