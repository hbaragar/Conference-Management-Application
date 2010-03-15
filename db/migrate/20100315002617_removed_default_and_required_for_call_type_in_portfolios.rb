class RemovedDefaultAndRequiredForCallTypeInPortfolios < ActiveRecord::Migration
  def self.up
    change_column :portfolios, :call_type, :string, :limit => 255, :default => nil
  end

  def self.down
    change_column :portfolios, :call_type, :string, :default => "for_presentations"
  end
end
