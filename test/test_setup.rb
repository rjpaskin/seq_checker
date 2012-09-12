require File.expand_path('../../config/setup.rb', __FILE__)

Bundler.require(:default, :test)

require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'