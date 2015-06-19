class AdjustStationCode < ActiveRecord::Migration
  def change
    change_column :stations, :station_code, :string
  end
end