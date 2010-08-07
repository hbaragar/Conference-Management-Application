class RenamedConferencesColocatedWithToHostingConference < ActiveRecord::Migration
  def self.up
    rename_column :conferences, :colocated_with_id, :hosting_conference_id
    Conference.all.each do |c|
      c.update_attributes(:hosting_conference_id => c.id) unless c.id
    end
    remove_index :conferences, :name => :index_conferences_on_colocated_with_id rescue ActiveRecord::StatementInvalid
    add_index :conferences, [:hosting_conference_id]
  end

  def self.down
    rename_column :conferences, :hosting_conference_id, :colocated_with_id
    Conference.all.each do |c|
      c.update_attributes(:colocated_with_id => nil) if c.colocated_with_id == c.id
    end
    remove_index :conferences, :name => :index_conferences_on_hosting_conference_id rescue ActiveRecord::StatementInvalid
    add_index :conferences, [:colocated_with_id]
  end
end
