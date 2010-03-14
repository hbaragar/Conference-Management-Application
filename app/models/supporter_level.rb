class SupporterLevel < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :call_for_supporter
  attr_readonly :call_for_supporter

  fields do
    name                 :string
    minimum_donation     :integer, :required, :default => 0
    medium_logo_max_area :integer, :required, :default => 0
    small_logo_max_area  :integer, :required, :default => 0
    description          :text
    timestamps
  end


  def portfolio
    call_for_supporter.portfolio
  end

  def conference
    portfolio.conference
  end

  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    return false if call_for_supporter_changed?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
