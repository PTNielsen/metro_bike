require 'httparty'
require 'json'
require 'Haversine'

class BikeShareAPI

  include HTTParty
  base_uri 'https://www.capitalbikeshare.com/data/stations/bikeStations.xml'

  def populate_bikeshare_table
    b = BikeShareAPI.get("")
    stations = b["stations"]["station"]
    stations.each do |s|
      Bikeshare.where({
        :name => s["name"],
        :bikeshare_latitude => s["lat"],
        :bikeshare_longitude => s["long"]
        }).first_or_create!
    end
  end

  def self.bikeshares_by_distance user_latitude, user_longitude
    bikeshare_haversine = []
    Bikeshare.all.each do |b|
      bd = (Haversine.distance(b.bikeshare_latitude, b.bikeshare_longitude, user_latitude, user_longitude)).to_mi
      bikeshare_haversine.push({
        :name => b.name,
        :bike_distance => bd
      })
    end
    bikeshare_haversine.sort_by { |i| i[:bike_distance] }
  end

  def self.realtime_bikes location
    b = BikeShareAPI.get("")
    stations = b["stations"]["station"]
    bike_availability = stations.map { |n| n.values_at("name", "nbBikes", "nbEmptyDocks", "latestUpdateTime") }
    bikeshare_array = bike_availability.select { |bike| bike[0] = "#{location}"}
    sorted_bike = bikeshare_array.sort_by { |b| b[3] }.reverse!.first
    realtime_bike = Hash[
      :name => sorted_bike[0],
      :bikes_available => sorted_bike[1],
      :empty_docks => sorted_bike[2],
      :last_update => sorted_bike[3]
    ]
  end

  def nearby_bikeshare_information user_latitude, user_longitude
    b = BikeShareAPI.bikeshares_by_distance user_latitude, user_longitude
    bike_data_array = []
    b.first(4).each do |brs|
      bike_data = {}
      bike_data[:name] = brs[:name]
      bike_data[:bd] = brs[:bike_distance]
      bike_data[:availability] = BikeShareAPI.realtime_bikes(brs[:name])
      bike_data_array.push bike_data
    end
    a = bike_data_array.drop(1)
    a.to_json
  end

end