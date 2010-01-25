class AddedCfps < ActiveRecord::Migration
  def self.up
    create_table :cfps do |t|
      t.integer  :portfolio_id
      t.date     :due_on
      t.string   :format_style, :default => "ACM Proceedings format"
      t.string   :format_url, :default => "http://cyberchair.acm.org/oopslapapers/submit/"
      t.string   :submit_to_url, :default => "http://cyberchair.acm.org/splash???/submit/"
      t.text     :details
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :cfps, [:portfolio_id]
  end

  def self.down
    drop_table :cfps
  end
end
