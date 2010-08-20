class AddedPositionToPresentations < ActiveRecord::Migration
  def self.up
    add_column :presentations, :position, :integer
    Session.all.each do |s|
      s.presentations.each_with_index do |p,i|
	p.position = i + 1
	p.save!
      end
    end
  end

  def self.down
    remove_column :presentations, :position
  end
end
