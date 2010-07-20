class AddedParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.string   :name
      t.string   :affiliation
      t.string   :private_email_address
      t.text     :bio
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :participants
  end
end
