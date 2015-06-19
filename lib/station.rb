class Station < ActiveRecord::Base
  validates_presence_of :station_code, :station_name, :line_1, :station_latitude, :station_longitude
  validates_uniqueness_of :station_code
end