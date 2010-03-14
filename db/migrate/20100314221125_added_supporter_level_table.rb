class AddedSupporterLevelTable < ActiveRecord::Migration
  def self.up
    create_table :supporter_levels do |t|
      t.integer  :call_for_supporter_id
      t.string   :name
      t.integer  :minimum_donation, :default => 0
      t.integer  :medium_logo_max_area, :default => 0
      t.integer  :small_logo_max_area, :default => 0
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :supporter_levels, [:call_for_supporter_id]

    change_column :cfps, :submit_to_url, :string, :limit => 255, :default => ""
  end

  def self.down
    change_column :cfps, :submit_to_url, :string, :default => "http://cyberchair.acm.org/splash???/submit/"

    drop_table :supporter_levels
  end
end
