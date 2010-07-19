class AddedPresentations < ActiveRecord::Migration
  def self.up
    create_table :presentations do |t|
      t.integer  :portfolio_id
      t.string   :title
      t.string   :short_title
      t.text     :abstract
      t.string   :external_reference
      t.string   :url
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :presentations, [:portfolio_id]
  end

  def self.down
    drop_table :presentations
  end
end
