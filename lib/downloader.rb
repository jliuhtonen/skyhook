module Skyhook
	class Downloader
		def initialize(storage, bucket_name)
			@storage = storage
			begin
				bucket_info = @storage.get_bucket(bucket_name)
			rescue Exception => e
				raise "No such bucket #{bucket_name}"
			end
			@bucket = @storage.directories.get(bucket_name)
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
					download_directory path
				end
			end
		end
	
	private
		def download_file(head)
			local_file_name = head.key.gsub(SKYHOOK_STORAGE_KEY, '')
			puts "Local file name #{local_file_name}"
			unless File.exists? local_file_name then
				File.open(local_file_name, 'w') do |file|
					file.write(@bucket.files.get(head.key).body)
				end
			else
				puts "Eek! It already exists"
			end
		end
		
		def download_directory(path)
			puts "should download directory #{path}"
		end
	end
end