require "minitest/autorun"
require "rack/test"
require 'pry'

ENV["TEST"] = "true"

require './db/setup'
require './lib/all'
require './server'

require_relative "./server"

class ServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MetroTransitApp
  end

  def setup
    Station.delete_all
    Bikeshare.delete_all
  end

  def test_nearest_stations
    a = Station.create!(station_code: "A03", station_name: "Dupont Circle", line_1: "RD", station_latitude: 38.9095980575, station_longitude: -77.0434143597)
    b = Station.create!(station_code: "A01", station_name: "Metro Center", line_1: "RD", station_latitude: 38.8983144732, station_longitude: -77.0280779971)
    c = Station.create!(station_code: "C10", station_name: "National Arpt", line_1: "BL", line_2: "YL", station_latitude: 38.8534163859, station_longitude: -77.0440422943)
    d = Station.create!(station_code: "D02", station_name: "Smithsonian", line_1: "BL", line_2: "OR", line_3: "SV", station_latitude: 38.888018702, station_longitude: -77.0280662342)

    get "/nearest_stations", user_latitude: 38.9059620, user_longitude: -77.0423670

    assert_equal 200, last_response.status

    response = JSON.parse last_response.body

    assert_equal 3, response.count
    assert_equal "Dupont Circle", response.first.fetch("station_name")
  end

  def test_nearest_bikeshares
    a = Bikeshare.create!(name: "S Joyce & Army Navy Dr", bikeshare_latitude: 38.8637, bikeshare_longitude: -77.0633)
    b = Bikeshare.create!(name: "20th & Crystal Dr", bikeshare_latitude: 38.8564, bikeshare_longitude: -77.0492)
    c = Bikeshare.create!(name: "5th & K St NW", bikeshare_latitude: 38.90304, bikeshare_longitude: -77.019027)
    d = Bikeshare.create!(name: "17th & K St NW", bikeshare_latitude: 38.90276, bikeshare_longitude: -77.03863)

    get "/nearest_bikeshares", user_latitude: 38.9059620, user_longitude: -77.0423670

    assert_equal 200, last_response.status

    response = JSON.parse last_response.body

    assert_equal 3, response.count
    assert_equal "5th & K St NW", response.first.fetch("name")
  end

end