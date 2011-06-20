class GenerateNewParticipantsForInvolvements < ActiveRecord::Migration

  def self.up
    Involvement.all.each do |i|
      conference_id = i.conference.id
      next if i.participant.conference.id == conference_id
      existing = i.participant
      i.participant = Participant.create(
	existing.attributes.merge(
	  "conference_id" => conference_id,
	  "created_at"	=> nil,
	  "updated_at"	=> nil
	)
      )
      i.save!
    end
  end

  def self.down
  end

end
