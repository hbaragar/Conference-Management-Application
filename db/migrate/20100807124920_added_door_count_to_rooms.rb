class AddedDoorCountToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :door_count, :integer
  end

  def self.down
    remove_column :rooms, :door_count
  end
end
