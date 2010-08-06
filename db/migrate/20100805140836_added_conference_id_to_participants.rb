class AddedConferenceIdToParticipants < ActiveRecord::Migration

  def self.up
    splashcon = Conference.find_by_name('SPLASH 2010')
    add_column :participants, :conference_id, :integer
    Participant.find(:all).each do |participant|
      participant.conference_id = splashcon.id
      participant.save!
    end
    add_index :participants, [:conference_id]
  end

  def self.down
    remove_column :participants, :conference_id
    remove_index :participants, :name => :index_participants_on_conference_id rescue ActiveRecord::StatementInvalid
  end

end
