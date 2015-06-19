require 'httparty'
require 'json'

class BikeShareAPI
  # Token = File.read "./token"

  include HTTParty

  attr_reader :stations

  def initialize
    b = HTTParty.get("http://www.capitalbikeshare.com/data/stations/bikeStations.xml")
    stations = b["stations"]["station"]
  end

  def populate_bikeshare_table
    stations.each do |s|
      Bikeshare.where({
        :name => s["name"],
        :bikeshare_latitude => s["lat"],
        :bikeshare_longitude => s["long"]
        }).first_or_create!
    end
  end
end