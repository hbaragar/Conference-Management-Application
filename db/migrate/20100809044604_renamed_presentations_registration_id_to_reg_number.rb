class RenamedPresentationsRegistrationIdToRegNumber < ActiveRecord::Migration
  def self.up
    rename_column :presentations, :registration_id, :reg_number
  end

  def self.down
    rename_column :presentations, :reg_number, :registration_id
  end
end
