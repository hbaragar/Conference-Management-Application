class AddedSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.integer  :portfolio_id
      t.string   :name
      t.datetime :starts_at, :default => "2010-10-22 08:00"
      t.datetime :ends_at, :default => "2010-10-22 09:00"
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :joomla_article_id
    end
    add_index :sessions, [:portfolio_id]
    add_index :sessions, [:joomla_article_id]

    add_column :presentations, :session_id, :integer

    add_index :presentations, [:session_id]
  end

  def self.down
    remove_column :presentations, :session_id

    drop_table :sessions

    remove_index :presentations, :name => :index_presentations_on_session_id rescue ActiveRecord::StatementInvalid
  end
end
