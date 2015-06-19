class Bikeshare < ActiveRecord::Base
  validates_presence_of :name, :bikeshare_latitude, :bikeshare_longitude
  validates_uniqueness_of :name
end