class AddedCallForSupportersTable < ActiveRecord::Migration
  def self.up
    create_table :call_for_supporters do |t|
      t.integer  :portfolio_id
      t.text     :details
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :call_for_supporters, [:portfolio_id]
  end

  def self.down
    drop_table :call_for_supporters
  end
end
