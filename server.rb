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
    s = wmata.station_distance params[:user_latitude].to_f, params[:user_longitude].to_f
    t = s.sort_by { |s| s[6] }
    train_data_array = []
    t.first(3).each do |trs|
      train_data = {}
      train_data[:station_name] = trs[1]
      train_data[:line_1] = trs[2]
      train_data[:line_2] = trs[3]
      train_data[:line_3] = trs[4]
      train_data[:line_4] = trs[5]
      train_data[:sd] = trs[6]
      train_data_array.push train_data
    end
    train_data_array.to_json
  end

  # get "/realtime_trains" do
  # end

  get "/nearest_bikeshares" do
    e = bike.bikeshare_distance params[:user_latitude].to_f, params[:user_longitude].to_f
    k = e.sort_by { |i| i[1] }
    bike_data_array = []
    k.first(4).each do |brs|
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