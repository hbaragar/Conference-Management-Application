class AddedCallTypeToPortfolio < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :call_type, :string, :required => true, :default => "for_presentations"
  end

  def self.down
    remove_column :portfolios, :call_type
  end
end
