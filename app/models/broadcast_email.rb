class BroadcastEmail < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :cfp

  fields do
    address :email_address
    timestamps
  end

  validates_uniqueness_of :address, :scope => :cfp_id

  default_scope :order => "address"


  def name
    address
  end

  def portfolio
    cfp.portfolio
  end

  def conference
    cfp.conference
  end


  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    return false if any_changed?(:cfp_id)
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
