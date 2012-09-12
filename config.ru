require 'rubygems'
require 'bundler'

# Load gems into load path, but don't require them
Bundler.setup

$LOAD_PATH << File.expand_path('../lib', __FILE__)

require './seq_check.rb'
run SeqCheck