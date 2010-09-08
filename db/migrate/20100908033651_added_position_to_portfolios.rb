class AddedPositionToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :position, :integer
  end

  def self.down
    remove_column :portfolios, :position
  end
end
