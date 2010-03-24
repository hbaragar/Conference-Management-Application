class CfpDate < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :cfp

  fields do
    label         :string, :required
    due_on_prefix :string, :default => ""
    due_on        :date, :required
  end

  default_scope :order => "due_on"

  def after_save
    cfp.changes_pending!
  end


  def portfolio
    cfp.portfolio
  end

  def conference
    cfp.conference
  end

  def name
    "#{label}: #{due_on_prefix}#{due_on.strftime('%B %d, %Y')}"
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
