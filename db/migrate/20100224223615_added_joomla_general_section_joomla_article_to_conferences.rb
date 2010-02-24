class AddedJoomlaGeneralSectionJoomlaArticleToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :joomla_general_section_id, :integer
    add_column :conferences, :joomla_article_id, :integer

    add_index :conferences, [:joomla_general_section_id]
    add_index :conferences, [:joomla_article_id]
  end

  def self.down
    remove_column :conferences, :joomla_general_section_id
    remove_column :conferences, :joomla_article_id

    remove_index :conferences, :name => :index_conferences_on_joomla_general_section_id rescue ActiveRecord::StatementInvalid
    remove_index :conferences, :name => :index_conferences_on_joomla_article_id rescue ActiveRecord::StatementInvalid
  end
end
