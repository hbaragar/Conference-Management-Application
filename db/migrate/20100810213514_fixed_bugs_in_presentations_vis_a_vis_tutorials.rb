class FixedBugsInPresentationsVisAVisTutorials < ActiveRecord::Migration
  def self.up
    rename_column :presentations, :audience_types, :audience
    change_column :presentations, :class_format, :text, :limit => nil
  end

  def self.down
    rename_column :presentations, :audience, :audience_types
    change_column :presentations, :class_format, :string
  end
end
