class AddedCountryToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :country, :string
  end

  def self.down
    remove_column :participants, :country
  end
end
