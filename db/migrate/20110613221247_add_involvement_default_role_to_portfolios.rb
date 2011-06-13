class AddInvolvementDefaultRoleToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :involvement_default_role, :string, :default => "author"
  end

  def self.down
    remove_column :portfolios, :involvement_default_role
  end
end
