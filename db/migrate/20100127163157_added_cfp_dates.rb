class AddedCfpDates < ActiveRecord::Migration
  def self.up
    create_table :cfp_dates do |t|
      t.integer :cfp_id
      t.string  :label
      t.string  :due_on_prefix, :default => ""
      t.date    :due_on
    end
    add_index :cfp_dates, [:cfp_id]
  end

  def self.down
    drop_table :cfp_dates
  end
end
