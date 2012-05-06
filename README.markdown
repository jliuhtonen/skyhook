# Skyhook

Skyhook is a (command line, for now) utility for backing up files in Amazon's S3 cloud storage service. 

Directories that are backed up are defined along with other settings in a YAML configuration file.

## Installation

Requirements:
-	Ruby 1.9.x
-	Rubygems
-	Fog gem: `gem install fog`

## Sample configuration yaml file

	aws_access_key_id: (your AWS access key)
	aws_secret_key_id: (your AWS secret key)
	bucket_name: (name for the bucket to back up to)
	backup:
	 - { path: /Users/janne/important_stuff }
	 - { path: /var/log/important/ }

## Usage

	GLaDOS:skyhook janne$ ruby skyhook.rb 
	Usage: skyhook.rb [options]
	-r, --recover PATH               Recover backed up file or directory
	-b, --backup [CONFIGFILE]        Make backups
	-v, --[no-]verbose               Verbose output

## License

Licensed under MIT license:

Copyright (c) 2012 Janne Liuhtonen

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
