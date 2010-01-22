class AddedConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.integer :colocated_with_id
      t.string  :name
      t.text    :description
    end
    add_index :conferences, [:colocated_with_id]
  end

  def self.down
    drop_table :conferences
  end
end
