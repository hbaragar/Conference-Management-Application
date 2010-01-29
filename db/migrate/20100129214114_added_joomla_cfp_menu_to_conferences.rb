class AddedJoomlaCfpMenuToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :joomla_cfp_menu_id, :integer

    add_column :cfps, :joomla_article_id, :integer

    add_index :conferences, [:joomla_cfp_menu_id]

    add_index :cfps, [:joomla_article_id]
  end

  def self.down
    remove_column :conferences, :joomla_cfp_menu_id

    remove_column :cfps, :joomla_article_id

    remove_index :conferences, :name => :index_conferences_on_joomla_cfp_menu_id rescue ActiveRecord::StatementInvalid

    remove_index :cfps, :name => :index_cfps_on_joomla_article_id rescue ActiveRecord::StatementInvalid
  end
end
