class AddedMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :portfolio_id
      t.boolean :chair, :default => false
      t.string  :role, :default => "member"
      t.string  :name
      t.string  :affiliation
      t.string  :email
      t.integer :user_id
    end
    add_index :members, [:portfolio_id]
    add_index :members, [:user_id]
  end

  def self.down
    drop_table :members
  end
end
