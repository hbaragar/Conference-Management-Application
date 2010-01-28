class QualifiedEmailAddressInMembersAndPortfolios < ActiveRecord::Migration
  def self.up
    rename_column :portfolios, :email_address, :public_email_address

    rename_column :members, :email_address, :private_email_address
  end

  def self.down
    rename_column :portfolios, :public_email_address, :email_address

    rename_column :members, :private_email_address, :email_address
  end
end
