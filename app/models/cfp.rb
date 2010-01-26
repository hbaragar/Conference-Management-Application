class Cfp < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    due_on        :date, :required
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :string, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    submit_to_url :string, :default => "http://cyberchair.acm.org/splash???/submit/"
    details       :text, :default => "To be completed by the portfolio chair"
    timestamps
  end


  def conference
    portfolio && portfolio.conference
  end

  # --- Permissions --- #

  attr_readonly :portfolio_id

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
