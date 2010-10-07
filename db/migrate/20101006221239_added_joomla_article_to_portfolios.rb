class AddedJoomlaArticleToPortfolios < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :joomla_article_id, :integer

    add_index :portfolios, [:joomla_article_id]
  end

  def self.down
    remove_column :portfolios, :joomla_article_id

    remove_index :portfolios, :name => :index_portfolios_on_joomla_article_id rescue ActiveRecord::StatementInvalid
  end
end
