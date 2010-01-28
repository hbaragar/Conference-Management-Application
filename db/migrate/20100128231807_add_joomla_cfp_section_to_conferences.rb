class AddJoomlaCfpSectionToConferences < ActiveRecord::Migration
  def self.up
    add_column :conferences, :joomla_cfp_section_id, :integer

    add_index :conferences, [:joomla_cfp_section_id]
  end

  def self.down
    remove_column :conferences, :joomla_cfp_section_id

    remove_index :conferences, :name => :index_conferences_on_joomla_cfp_section_id rescue ActiveRecord::StatementInvalid
  end
end
