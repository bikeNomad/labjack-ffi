# -*- ruby -*-

require 'rubygems'
require 'rake/clean'

LIB="lib"
SRC="src"

CLEAN.include("#{SRC}/labjackusb.xml")

task :test do
#	sh "ruby -I#{LIB} #{LIB}/labjack.rb"
end

require 'hoe'

Hoe.spec 'labjack' do |p|
  p.developer('Ned Konz', 'ned+ruby@bike-nomad.com')
  p.version = '0.1'
#  p.dependency('simplecov','0.6.4',:dev)
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
  sh "/usr/local/bin/ctags --ruby-kinds=cfmF --recurse=yes #{LIB}"
end

# vim: syntax=ruby
