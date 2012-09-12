require 'rubygems'
require 'bundler'

# Load gems into load path, but don't require them
Bundler.setup

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require File.expand_path('../../seq_check.rb', __FILE__)

require 'test/unit'
require 'rack/test'

class SeqCheckTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    SeqCheck
  end
  
  def test_index
    get '/'
    assert last_response.ok?
  end
end