class AddedConflictedToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :conflicted, :boolean
  end

  def self.down
    remove_column :rooms, :conflicted
  end
end
