class AddedConflictedToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :conflicted, :boolean
  end

  def self.down
    remove_column :participants, :conflicted
  end
end
