class AddLifecycleToSessions < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :state, :string, :default => "unpublished"
    add_column :portfolios, :key_timestamp, :datetime

    Portfolio.all.each do |s|
      s.state = 'published' if s.sessions.count > 0
      s.save
    end

    add_index :portfolios, [:state]
  end

  def self.down
    remove_column :portfolios, :state
    remove_column :portfolios, :key_timestamp

    remove_index :portfolios, :name => :index_portfolios_on_state rescue ActiveRecord::StatementInvalid
  end
end
