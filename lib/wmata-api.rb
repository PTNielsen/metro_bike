require 'httparty'
require 'json'
require 'Haversine'

class WMATAAPI

  Token = File.read "authkey.txt"

  include HTTParty 
  base_uri "https://api.wmata.com"

  def populate_station_table
    st = WMATAAPI.get("/Rail.svc/json/jStations", query: {api_key: "#{Token}"})
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

  def self.stations_by_distance user_latitude, user_longitude
    station_haversine = []
    Station.all.each do |s|
      sd = (Haversine.distance(s.station_latitude, s.station_longitude, user_latitude, user_longitude)).to_mi
      station_haversine.push({
        :station_code => s.station_code,
        :station_name => s.station_name,
        :line_1 => s.line_1,
        :line_2 =>s.line_2,
        :line_3 => s.line_3,
        :line_4 => s.line_4,
        :station_distance => sd
      })
    end
    station_haversine.sort_by { |s| s[:station_distance] }
  end

  def self.realtime_station code
    rs = WMATAAPI.get("/StationPrediction.svc/json/GetPrediction/#{code}", query: {api_key: "#{Token}"})
    realtime_trains = rs["Trains"].map { |n| n.values_at("LocationCode", "LocationName", "Line", "Destination", "Min") }
    realtime_trains = realtime_trains.map { |train| Hash[
      :location_code => train[0],
      :location_name => train[1],
      :line => train[2], 
      :destination => train[3], 
      :min => train[4]
      ] }
    realtime_trains.first(5)
  end

  def nearby_station_information user_latitude, user_longitude
    s = WMATAAPI.stations_by_distance user_latitude, user_longitude
    train_data_array = []
    s.first(3).each do |trs|
      train_data = {}
      train_data[:station_name] = trs[:station_name]
      train_data[:line_1] = trs[:line_1]
      train_data[:line_2] = trs[:line_2]
      train_data[:line_3] = trs[:line_3]
      train_data[:line_4] = trs[:line_4]
      train_data[:station_distance] = trs[:station_distance]
      train_data[:upcoming] = WMATAAPI.realtime_station(trs[:station_code])
      train_data_array.push train_data
    end
    train_data_array
  end

end