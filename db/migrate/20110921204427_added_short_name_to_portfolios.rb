class AddedShortNameToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :short_name, :string
  end

  def self.down
    remove_column :portfolios, :short_name
  end
end
