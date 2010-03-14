class CallForSupporter < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  attr_readonly :portfolio_id

  fields do
    details :markdown
    timestamps
  end


  def conference
    portfolio && portfolio.conference
  end


  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    return true if acting_user.administrator?
    none_changed?(:portfolio_id) && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
