class AddedShortNameToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :short_name, :string
    Session.all.select{|s| s.single_presentation?}.each do |s|
      s.short_name = s.presentations.first.short_title
      s.save
    end
  end

  def self.down
    remove_column :sessions, :short_name
  end
end
