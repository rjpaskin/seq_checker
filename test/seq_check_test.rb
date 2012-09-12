require File.expand_path('../test_setup.rb', __FILE__)

class SeqCheckTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    SeqCheck
  end
  
  def test_index
    get '/'
    assert last_response.ok?
    assert last_response.content_length > 0
  end
end