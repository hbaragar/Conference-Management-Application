class AddedJoomlaStuffToSessions < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :joomla_category_id, :integer
    add_column :portfolios, :joomla_menu_id, :integer

    add_index :portfolios, [:joomla_category_id]
    add_index :portfolios, [:joomla_menu_id]
  end

  def self.down
    remove_column :portfolios, :joomla_category_id
    remove_column :portfolios, :joomla_menu_id

    remove_index :portfolios, :name => :index_portfolios_on_joomla_category_id rescue ActiveRecord::StatementInvalid
    remove_index :portfolios, :name => :index_portfolios_on_joomla_menu_id rescue ActiveRecord::StatementInvalid
  end
end
