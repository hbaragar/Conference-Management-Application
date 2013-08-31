class AddedChairsToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :chair_id, :integer
    change_column :sessions, :starts_at, :datetime, :default => "2013-10-26 08:00"

    add_index :sessions, [:chair_id]
  end

  def self.down
    remove_column :sessions, :chair_id
    change_column :sessions, :starts_at, :datetime, :default => '2011-10-22 08:00:00'

    remove_index :sessions, :name => :index_sessions_on_chair_id rescue ActiveRecord::StatementInvalid
  end
end
