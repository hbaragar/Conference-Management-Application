class ChangedDefaultSessionStartsAtTime < ActiveRecord::Migration
  def self.up
    change_column :sessions, :starts_at, :datetime, :default => "2011-10-22 08:00"
  end

  def self.down
    change_column :sessions, :starts_at, :datetime, :default => '2010-10-22 08:00:00'
  end
end
