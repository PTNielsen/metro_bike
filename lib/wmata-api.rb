require 'httparty'
require 'json'
require 'Haversine'

class WMATAAPI
  # Token = File.read "./token"

  Token = File.read "authkey.txt"

  include HTTParty 
  base_uri "https://api.wmata.com"

  def populate_station_table
    st = HTTParty.get("https://api.wmata.com/Rail.svc/json/jStations", query: {api_key: "#{Token}"})
    st["Stations"].each do |s|
      Station.where({
        :station_code => s["Code"],
        :station_name => s["Name"],
        :line_1 => s["LineCode1"],
        :line_2 => s["LineCode2"],
        :line_3 => s["LineCode3"],
        :line_4 => s["LineCode4"],
        :station_latitude => s["Lat"],
        :station_longitude => s["Lon"]
      }).first_or_create!
    end
  end

  def station_distance user_latitude, user_longitude
    station_haversine = []
    Station.all.each do |s|
      sd = (Haversine.distance(s.station_latitude, s.station_longitude, user_latitude, user_longitude)).to_mi
      station_haversine.push([s.station_code, s.station_name, s.line_1, s.line_2, s.line_3, s.line_4, sd])
    end
    station_haversine
  end

  # def realtime_station
  #   rs = HTTParty.get("https://api.wmata.com/StationPrediction.svc/json/GetPrediction/All", query: {api_key: "#{Token}"})
  #   current_trains = rs["Trains"].map { |n| n.values_at("LocationCode", "LocationName", "Line", "Destination", "Min") }
  #   binding.pry
  #   #current_trains.select { |train| train[0] = "LOCATIONNAME" }
  # end

end