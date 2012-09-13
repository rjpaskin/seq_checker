require File.expand_path('../../test_setup.rb', __FILE__)

class SeqCheckTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    SeqCheck
  end
  
  def flash
    last_request.env['x-rack.flash']
  end
  
  def test_index
    get '/'
    assert last_response.ok?
    assert last_response.content_length > 0
  end
  
  def test_post_to_index_with_empty_parameters
    post '/'
    
    assert last_response.redirect?
    
    follow_redirect!
    
    assert last_response.body.include? 'error'
    assert flash[:error]
    assert last_response.ok?
    
    get '/'
    assert_equal flash[:error], nil
  end
end