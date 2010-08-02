class AddedFacilityAreas < ActiveRecord::Migration
  def self.up
    create_table :facility_areas do |t|
      t.integer  :conference_id
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :joomla_article_id
    end
    add_index :facility_areas, [:conference_id]
    add_index :facility_areas, [:joomla_article_id]

    add_column :rooms, :facility_area_id, :integer
    remove_column :rooms, :area

    add_index :rooms, [:facility_area_id]
  end

  def self.down
    remove_column :rooms, :facility_area_id
    add_column :rooms, :area, :string

    drop_table :facility_areas

    remove_index :rooms, :name => :index_rooms_on_facility_area_id rescue ActiveRecord::StatementInvalid
  end
end
