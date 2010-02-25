class AddedUrlAndLogoUrlToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :url, :string
    add_column :conferences, :logo_url, :string
  end

  def self.down
    remove_column :conferences, :url
    remove_column :conferences, :logo_url
  end
end
