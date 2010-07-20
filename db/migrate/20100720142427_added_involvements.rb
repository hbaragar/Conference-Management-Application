class AddedInvolvements < ActiveRecord::Migration
  def self.up
    create_table :involvements do |t|
      t.integer  :participant_id
      t.integer  :presentation_id
      t.string   :role
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :involvements, [:participant_id]
    add_index :involvements, [:presentation_id]
  end

  def self.down
    drop_table :involvements
  end
end
