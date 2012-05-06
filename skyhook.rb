def require_relative(required)
	require File.join(File.dirname(__FILE__), required)
end

require_relative 'uploader.rb'
require_relative 'cli.rb'

if __FILE__ == $0 then
	Skyhook::Cli.new.run
end