require "minitest/autorun"
require "rack/test"
require 'pry'

ENV["TEST"] = "true"

require './db/setup'
require './lib/all'
require './server'

require_relative "./server"

class ServerTest < Minitest::Test
  include Rack::Test::Methods
  
end