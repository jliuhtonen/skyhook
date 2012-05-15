module Skyhook
	class Downloader
        attr_accessor :overwrite_confirmation

		def initialize(storage, bucket_name)
			@storage = storage
			begin
				bucket_info = @storage.get_bucket(bucket_name)
			rescue Exception => e
				raise "No such bucket #{bucket_name}"
			end
			@bucket = @storage.directories.get(bucket_name)
            @overwrite = nil
		end
		
		def download(paths)
			paths.each do |path|
				#what is this path thing anyways...
				#hmm.. maybe its a file? 
				key = "#{SKYHOOK_STORAGE_KEY}#{path}"
				puts "looking for #{key}"
				remote_file_head = @bucket.files.head(key)
				if remote_file_head then
					#yup, it's a file
					download_file remote_file_head
				else
					#nope, maybe its a directory?
					download_directory key
				end
			end
		end
	
	private
		def download_file(remote_file)
			local_file_name = remote_file.key.gsub(SKYHOOK_STORAGE_KEY, '')			

			write = true

			remote_head = @bucket.files.head(remote_file.key)

            puts "Local file name #{local_file_name}"
			if File.exists? local_file_name then
				if remote_head.metadata[Metadata::CHECKSUM].eql? HashCalculator.calculate(local_file_name)
					write = false
					puts "Local file already up to date, skipping..."
				else
                	dialog_result = @overwrite_confirmation.call("Not identical #{local_file_name} exists.")
                	@overwrite ||= dialog_result == :all
                	write = @overwrite or dialog_result == :yes
                end 
			end
			
			get(remote_file, local_file_name, remote_head) if write
			
		end

        def get(remote_file, file_name, head)
        
        	dir = File.dirname(file_name)
        	unless Dir.exists? dir then
        		FileUtils.mkdir_p dir
        	end
        	
            File.open(file_name, 'w') do |file|
            	if head.metadata[Metadata::COMPRESSED] then
            		download_and_decompress(remote_file, file_name)
            	else
					file.write(@bucket.files.get(remote_file.key).body)
				end
			end
			puts "Wrote to #{file_name}"
        end
        
        def download_and_decompress(remote_file, file_name)
        	begin
        		tmpfile = Tempfile.new('skyhook')
        		tmpfile.write(@bucket.files.get(remote_file.key).body)
        		tmpfile.close
        		File.open(file_name, 'w') do |file|
        			Zlib::GzipReader.open(tmpfile.path) do |gz|
 				    	file.write gz.read
					end
        		end
        	ensure
        		tmpfile.unlink if tmpfile
        	end
        end
		
		def download_directory(path)
			@bucket.files.all(:prefix => path).each do |remote_file|
				download_file remote_file
			end
		end
	end
end
