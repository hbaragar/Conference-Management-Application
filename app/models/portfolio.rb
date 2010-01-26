class Portfolio < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name        :string, :required
    email_address :email_address
    description :markdown
  end

  has_many :members, :dependent => :destroy
  has_many :cfps, :dependent => :destroy	# Really only one, but we want the hobo support

  def chair? user
    (members & user.members).select do |m|
      m.chair
    end.count > 0
  end


  # --- Permissions --- #

  attr_readonly :conference_id

  def create_permitted?
    return true if acting_user.administrator?
    conference && conference.chair?(acting_user)
  end

  def update_permitted?
    return false if name_changed? && name_was == "General"
    return false if any_changed?(:conference_id) && !acting_user.administrator?
    chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    return false if name == "General"
    members.empty? && (conference.chair?(acting_user) || acting_user.administrator?)
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
