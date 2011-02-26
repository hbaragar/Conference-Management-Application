class AddedExternalReviewers < ActiveRecord::Migration
  def self.up
    create_table :external_reviewers do |t|
      t.integer  :call_id
      t.string   :name
      t.string   :affiliation
      t.string   :country
      t.string   :private_email_address
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :external_reviewers, [:call_id]
  end

  def self.down
    drop_table :external_reviewers
  end
end
