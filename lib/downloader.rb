module Skyhook
	class Downloader
		def initialize(storage, bucket_name, options = {})
			@storage = storage
			begin
				bucket_info = @storage.get_bucket(bucket_name)
				p bucket_info
			rescue Exception => e
				raise "No such bucket #{bucket_name}"
			end
		end
		
		def download(paths)
			paths.each do |path|
				if FileTest.directory? path then
					download_directory path
				else
					download_file path
				end
			end
		end
	
	private
		def download_directory(path)
			#@storage.files.all(:prefix =>)
		end
		
		def download_file(path)
			remote_file = @storage.files.get(path)
		end
		
	end
end