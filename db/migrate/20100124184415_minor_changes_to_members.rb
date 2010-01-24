class MinorChangesToMembers < ActiveRecord::Migration
  def self.up
    rename_column :members, :email, :email_address
    remove_column :members, :role
  end

  def self.down
    rename_column :members, :email_address, :email
    add_column :members, :role, :string, :default => "member"
  end
end
