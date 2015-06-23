require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require 'httparty'

class MetroTransitApp < Sinatra::Base
  enable :logging
  enable :method_override
  enable :sessions

  set :session_secret, (ENV["SESSION_SECRET"] || "development")

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :get
    end
  end

  before do
    headers["Content-Type"] = "application/json"
  end

  wmata = WMATAAPI.new
  bike = BikeShareAPI.new

  get "/nearest_stations" do
    wmata.nearby_station_information params[:user_latitude].to_f, params[:user_longitude].to_f
  end

  get "/nearest_bikeshares" do
    bike.nearby_bikeshare_information params[:user_latitude].to_f, params[:user_longitude].to_f
  end

end

MetroTransitApp.run! if $PROGRAM_NAME == __FILE__