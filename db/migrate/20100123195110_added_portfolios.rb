class AddedPortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios do |t|
      t.integer :conference_id
      t.string  :name
      t.text    :description
    end
    add_index :portfolios, [:conference_id]
  end

  def self.down
    drop_table :portfolios
  end
end
