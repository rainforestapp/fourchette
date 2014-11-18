require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end
