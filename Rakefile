# -*- ruby -*-

require 'rubygems'
require 'rake/clean'
require 'hoe'

Hoe.spec 'labjack' do |p|
  p.developer('Ned Konz', 'ned+ruby@bike-nomad.com')
  p.version = '0.1'
  p.dependency('simplecov','0.6.4',:dev)
end

LIB="lib"
SRC="src"

CLEAN.include("#{LIB}/labjack_ffi.rb","#{SRC}/labjackusb.xml")

# ensure that generated Ruby is packaged too
task :package => [ :generate ] do
end

task :test => [ :generate ] do
	sh "ruby -I#{LIB} #{LIB}/labjack.rb"
end

task :generate => [ "#{LIB}/labjack_ffi.rb" ] do
end

file "#{LIB}/labjack_ffi.rb" => [ "#{SRC}/labjackusb.xml" ] do
	sh "ffi-gen #{SRC}/labjackusb.xml #{LIB}/labjack_ffi.rb"
	sh "ruby -i -p -e '$_.gsub!(/\\bFFI::(Struct|Library)\\b/, \"NiceFFI::\\\\1\")' #{LIB}/labjack_ffi.rb"
end

file "#{SRC}/labjackusb.xml" => [ "#{SRC}/LJ.i" ] do
	sh "swig -xml -I/usr/local/include -o #{SRC}/labjackusb.xml #{SRC}/LJ.i"
end

task :clean do
end

file "tags" do
	sh "ctags -R #{LIB}"
end

# vim: syntax=ruby
