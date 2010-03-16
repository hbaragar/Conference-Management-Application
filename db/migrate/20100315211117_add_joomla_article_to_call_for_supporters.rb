class AddJoomlaArticleToCallForSupporters < ActiveRecord::Migration
  def self.up
    change_column :portfolios, :call_type, :string, :limit => 255, :default => "no_call"

    add_column :call_for_supporters, :joomla_article_id, :integer

    add_index :call_for_supporters, [:joomla_article_id]
  end

  def self.down
    change_column :portfolios, :call_type, :string

    remove_column :call_for_supporters, :joomla_article_id

    remove_index :call_for_supporters, :name => :index_call_for_supporters_on_joomla_article_id rescue ActiveRecord::StatementInvalid
  end
end
