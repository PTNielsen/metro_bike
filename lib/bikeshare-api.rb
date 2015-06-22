require 'httparty'
require 'json'
require 'Haversine'

class BikeShareAPI

  include HTTParty

  attr_reader :stations, :b

  def initialize
    b = HTTParty.get("http://www.capitalbikeshare.com/data/stations/bikeStations.xml")
    @stations = b["stations"]["station"]
  end

  def populate_bikeshare_table
    @stations.each do |s|
      Bikeshare.where({
        :name => s["name"],
        :bikeshare_latitude => s["lat"],
        :bikeshare_longitude => s["long"]
        }).first_or_create!
    end
  end

  def bikeshares_by_distance user_latitude, user_longitude
    bikeshare_haversine = []
    Bikeshare.all.each do |b|
      bd = (Haversine.distance(b.bikeshare_latitude, b.bikeshare_longitude, user_latitude, user_longitude)).to_mi
      bikeshare_haversine.push([b.name, bd])
    end
    bikeshare_haversine.sort_by { |i| i[1] }
  end

  def realtime_bikes
    bike_availability = @stations.map { |n| n.values_at("name", "nbBikes", "nbEmptyDocks") }
  end

end