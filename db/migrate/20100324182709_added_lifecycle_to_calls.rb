class AddedLifecycleToCalls < ActiveRecord::Migration
  def self.up
    add_column :calls, :state, :string, :default => "unpublished"
    add_column :calls, :key_timestamp, :datetime

    Call.all.each do |c|
      c.state = 'published'
      c.save
    end

    add_index :calls, [:state]
  end

  def self.down
    remove_column :calls, :state
    remove_column :calls, :key_timestamp

    remove_index :calls, :name => :index_calls_on_state rescue ActiveRecord::StatementInvalid
  end
end
