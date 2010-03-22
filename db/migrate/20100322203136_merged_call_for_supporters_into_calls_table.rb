class MergedCallForSupportersIntoCallsTable < ActiveRecord::Migration
  def self.up
    drop_table :call_for_supporters
  end

  def self.down
    create_table "call_for_supporters", :force => true do |t|
      t.integer  "portfolio_id"
      t.text     "details"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "joomla_article_id"
    end

    add_index "call_for_supporters", ["joomla_article_id"], :name => "index_call_for_supporters_on_joomla_article_id"
    add_index "call_for_supporters", ["portfolio_id"], :name => "index_call_for_supporters_on_portfolio_id"
  end
end
