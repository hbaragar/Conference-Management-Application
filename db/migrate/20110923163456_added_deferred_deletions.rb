class AddedDeferredDeletions < ActiveRecord::Migration
  def self.up
    create_table :deferred_deletions do |t|
      t.integer  :joomla_article_id
      t.integer  :joomla_category_id
      t.integer  :joomla_menu_id
      t.integer  :joomla_section_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :deferred_deletions
  end
end
