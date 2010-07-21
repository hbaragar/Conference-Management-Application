class ChangedDefaultForSessionsName < ActiveRecord::Migration
  def self.up
    change_column :sessions, :name, :string, :limit => 255, :default => "To Be Scheduled"
  end

  def self.down
    change_column :sessions, :name, :string, :default => "Unscheduled"
  end
end
