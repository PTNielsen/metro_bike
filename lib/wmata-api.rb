require 'httparty'
require 'json'

class WMATAAPI
  # Token = File.read "./token"

  include HTTParty 
  base_uri "https://api.wmata.com"

  def populate_station_table
    r = HTTParty.get("https://api.wmata.com/Rail.svc/json/jStations", query: {api_key: "7bb946399680431ebff34224ad4d905d"})
    r["Stations"].each do |s|
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
end