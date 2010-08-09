class AddedTutorialFieldsToPresentations < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :presentation_fields, :string, :default => "title, short_title, external_reference, abstract"

    add_column :presentations, :registration_id, :string
    add_column :presentations, :class_type, :string
    add_column :presentations, :class_format, :string
    add_column :presentations, :audience_types, :string
    add_column :presentations, :objectives, :text
    add_column :presentations, :resume, :text
  end

  def self.down
    remove_column :portfolios, :presentation_fields

    remove_column :presentations, :registration_id
    remove_column :presentations, :class_type
    remove_column :presentations, :class_format
    remove_column :presentations, :audience_types
    remove_column :presentations, :objectives
    remove_column :presentations, :resume
  end
end
