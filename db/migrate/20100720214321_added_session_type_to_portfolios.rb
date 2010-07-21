class AddedSessionTypeToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :session_type, :string, :default => "no_sessions"

    change_column :sessions, :name, :string, :limit => 255, :default => "Unscheduled"
  end

  def self.down
    remove_column :portfolios, :session_type

    change_column :sessions, :name, :string
  end
end
