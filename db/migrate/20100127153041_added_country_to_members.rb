class AddedCountryToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :country, :string
  end

  def self.down
    remove_column :members, :country
  end
end
