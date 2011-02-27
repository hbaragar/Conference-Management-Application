class ExternalReviewer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :cfp

  fields do
    name                  :string
    affiliation           :string
    country               :string
    private_email_address :email_address
    timestamps
  end

  default_scope :order => 'name'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :cfp_id

  def after_save
    cfp.changes_pending! if cfp
  end

  def portfolio
    cfp.portfolio
  end

  def conference
    portfolio.conference
  end

  def to_html
    name.to_html
  end


  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
