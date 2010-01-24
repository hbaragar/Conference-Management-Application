class Portfolio < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name        :string, :required
    email_address :email_address
    description :markdown
  end

  has_many :members, :dependent => :destroy

  def chair? user
    (members & user.members).select do |m|
      m.chair
    end.count > 0
  end


  # --- Permissions --- #

  attr_readonly :conference_id

  def create_permitted?
    conference.chair?(acting_user) || acting_user.administrator?
  end

  def update_permitted?
    chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    return false if name == "General"
    members.empty? && (conference.chair?(acting_user) || acting_user.administrator?)
  end

  def view_permitted?(field)
    true
  end

end
