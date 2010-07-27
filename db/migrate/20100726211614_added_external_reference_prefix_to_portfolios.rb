class AddedExternalReferencePrefixToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :external_reference_prefix, :string
  end

  def self.down
    remove_column :portfolios, :external_reference_prefix
  end
end
