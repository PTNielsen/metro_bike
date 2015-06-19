require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require 'haversine'
require './wmata-api'
require './bikeshare-api'

class MetroBikeApp < Sinatra::Base
  enable :logging
  enable :method_override
  enable :sessions

  # wmata = WMATAAPI.new
  # bike = BikeShareAPI.new

  # def station_haversine user_latitude, user_longitude
  #   closest_stations = {}
  #   Station.each do |s|
  #     station_distance = Haversine.distance(s.station_latitude, s.station_longitude, params[:user_latitude], params[:user_longitude])
  #     closest_stations.push station_distance.to_mi
  #   end
  #   closest_station.sort_by (station_distance)
  # end

  # def bikeshare_distance latitude, longitude
  #   closest_bikeshare = []
  #   bikeshare_distance = Haversine.distance(Bikeshare.latitude, Bikeshare.longitude, params[:user_latitude], params[:user_longitude])

  # end

end