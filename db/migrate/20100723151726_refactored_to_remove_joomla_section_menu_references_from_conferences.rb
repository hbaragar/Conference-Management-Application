class RefactoredToRemoveJoomlaSectionMenuReferencesFromConferences < ActiveRecord::Migration
  def self.up
    remove_column :conferences, :joomla_program_section_id
    remove_column :conferences, :joomla_cfp_menu_id
    remove_column :conferences, :joomla_cfp_section_id
    remove_column :conferences, :joomla_program_menu_id
    remove_column :conferences, :joomla_general_section_id

    remove_index :conferences, :name => :index_conferences_on_joomla_cfp_section_id rescue ActiveRecord::StatementInvalid
    remove_index :conferences, :name => :index_conferences_on_joomla_cfp_menu_id rescue ActiveRecord::StatementInvalid
    remove_index :conferences, :name => :index_conferences_on_joomla_general_section_id rescue ActiveRecord::StatementInvalid
    remove_index :conferences, :name => :index_conferences_on_joomla_program_section_id rescue ActiveRecord::StatementInvalid
    remove_index :conferences, :name => :index_conferences_on_joomla_program_menu_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :conferences, :joomla_program_section_id, :integer
    add_column :conferences, :joomla_cfp_menu_id, :integer
    add_column :conferences, :joomla_cfp_section_id, :integer
    add_column :conferences, :joomla_program_menu_id, :integer
    add_column :conferences, :joomla_general_section_id, :integer

    add_index :conferences, [:joomla_cfp_section_id]
    add_index :conferences, [:joomla_cfp_menu_id]
    add_index :conferences, [:joomla_general_section_id]
    add_index :conferences, [:joomla_program_section_id]
    add_index :conferences, [:joomla_program_menu_id]
  end
end
