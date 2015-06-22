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
    b = bike.bikeshares_by_distance params[:user_latitude].to_f, params[:user_longitude].to_f
    bike_data_array = []
    b.first(4).each do |brs|
      bike_data = {}
      bike_data[:name] = brs[0]
      bike_data[:bd] = brs[1]

      bike_data_array.push bike_data
    end
    a = bike_data_array.drop(1)
    a.to_json
  end

end

MetroTransitApp.run! if $PROGRAM_NAME == __FILE__