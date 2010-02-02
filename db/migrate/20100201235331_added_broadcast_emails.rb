class AddedBroadcastEmails < ActiveRecord::Migration
  def self.up
    create_table :broadcast_emails do |t|
      t.integer  :cfp_id
      t.string   :address
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :broadcast_emails, [:cfp_id]
  end

  def self.down
    drop_table :broadcast_emails
  end
end
