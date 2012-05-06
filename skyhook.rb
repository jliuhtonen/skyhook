require 'fog'
require 'find'
require 'optparse'
require File.join(File.dirname(__FILE__), 'uploader.rb')
require File.join(File.dirname(__FILE__), 'cli.rb')

if __FILE__ == $0 then
	Skyhook::Cli.new.run
end