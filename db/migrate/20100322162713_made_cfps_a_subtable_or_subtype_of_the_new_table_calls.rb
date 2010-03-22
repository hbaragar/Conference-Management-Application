class MadeCfpsASubtableOrSubtypeOfTheNewTableCalls < ActiveRecord::Migration

  def self.up
    rename_table :cfps, :calls

    add_column :calls, :type, :string

    Call.all.each {|c| c.type = "Cfp"; c.save}

    remove_index :calls, :name => :index_cfps_on_portfolio_id rescue ActiveRecord::StatementInvalid
    remove_index :calls, :name => :index_cfps_on_joomla_article_id rescue ActiveRecord::StatementInvalid
    add_index :calls, [:portfolio_id]
    add_index :calls, [:joomla_article_id]
    add_index :calls, [:type]
  end

  def self.down
    remove_column :calls, :type

    rename_table :calls, :cfps

    remove_index :cfps, :name => :index_calls_on_portfolio_id rescue ActiveRecord::StatementInvalid
    remove_index :cfps, :name => :index_calls_on_joomla_article_id rescue ActiveRecord::StatementInvalid
    remove_index :cfps, :name => :index_calls_on_type rescue ActiveRecord::StatementInvalid
    add_index :cfps, [:portfolio_id]
    add_index :cfps, [:joomla_article_id]
  end

end
