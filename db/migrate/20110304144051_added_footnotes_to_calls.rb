class AddedFootnotesToCalls < ActiveRecord::Migration
  def self.up
    add_column :calls, :footnotes, :text
  end

  def self.down
    remove_column :calls, :footnotes
  end
end
