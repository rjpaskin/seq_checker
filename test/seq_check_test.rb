require File.expand_path('../../config/setup.rb', __FILE__)

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