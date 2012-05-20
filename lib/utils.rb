module Skyhook
	class HashCalculator
		def self.calculate(filepath)
			md5 = File.open(filepath, 'rb') do |stream|
  				digest = Digest::MD5.new
  				buffer = ""
  				digest.update(buffer) while stream.read(@@BUFFER_SIZE, buffer)
  				return digest.to_s
			end
		end
	private
		@@BUFFER_SIZE = 4096
	end
	
	class AWStorageFactory
		def self.create(config)
			Fog::Storage.new({
  				:provider                 => 'AWS',
  				:aws_access_key_id        => config['aws_access_key_id'],
  				:aws_secret_access_key    => config['aws_secret_key_id'],
  				:region					  => config['region']
			})
		end
	end
end