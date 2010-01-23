class AddEmailAddressToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :email_address, :string
  end

  def self.down
    remove_column :portfolios, :email_address
  end
end
