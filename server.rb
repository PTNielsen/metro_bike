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

  wmata = WMATAAPI.new
  bike = BikeShareAPI.new

  get "/nearest_stations" do
    s = wmata.station_distance params[:user_latitude].to_f, params[:user_longitude].to_f
    t = s.sort_by { |s| s[6] }
    t.first(3).to_json
  end

  get "/nearest_bikeshares" do
    e = bike.bikeshare_distance params[:user_latitude].to_f, params[:user_longitude].to_f
    k = e.sort_by { |i| i[1] }
    k.first(3).to_json
  end

end