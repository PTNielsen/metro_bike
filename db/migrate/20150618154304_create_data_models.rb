class CreateDataModels < ActiveRecord::Migration
  def change
    create_table "stations" do |t|
      t.integer "station_code"
      t.string "station_name"
      t.string "line_1"
      t.string "line_2"
      t.string "line_3"
      t.string "line_4"
      t.float "station_latitude"
      t.float "station_longitude"
    end

    create_table "bikeshares" do |t|
      t.string "name"
      t.float "bikeshare_latitude"
      t.float "bikeshare_longitude"
    end
  end
end