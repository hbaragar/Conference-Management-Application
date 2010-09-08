class AddedPositionToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :position, :integer
  end

  def self.down
    remove_column :conferences, :position
  end
end
