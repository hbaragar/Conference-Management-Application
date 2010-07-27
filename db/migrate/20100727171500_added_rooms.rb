class AddedRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string   :name
      t.string   :capacity
      t.string   :area
      t.string   :short_name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :portfolios, :typical_session_duration, :integer, :default => 90

    add_column :sessions, :duration, :integer
    add_column :sessions, :room_id, :integer
    remove_column :sessions, :ends_at

    add_index :sessions, [:room_id]
  end

  def self.down
    remove_column :portfolios, :typical_session_duration

    remove_column :sessions, :duration
    remove_column :sessions, :room_id
    add_column :sessions, :ends_at, :datetime, :default => '2010-10-22 09:00:00'

    drop_table :rooms

    remove_index :sessions, :name => :index_sessions_on_room_id rescue ActiveRecord::StatementInvalid
  end
end
