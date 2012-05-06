require 'fog'
require 'find'
require 'optparse'
require './uploader.rb'
require './cli.rb'

if __FILE__ == $0 then
	Skyhook::Cli.new.run
end