class AddedPositionToPresentations < ActiveRecord::Migration
  def self.up
    add_column :presentations, :position, :integer
  end

  def self.down
    remove_column :presentations, :position
  end
end
