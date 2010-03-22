class Call < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio
  attr_readonly :portfolio_id

  fields do
    due_on        :date, :required
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :string, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    submit_to_url :string, :default => ""
    details       :markdown
    timestamps
  end


  belongs_to :joomla_article

  has_many :members, :through => :portfolio


  def name
    portfolio.to_s
  end

  def portfolio_description
    portfolio.description
  end

  def conference
    portfolio.conference
  end

  def conference_description
    conference.description
  end

  def chairs
    portfolio.chairs.join(" and ")
  end

  def email_address
    portfolio.public_email_address
  end

  # --- Permissions --- #

  never_show :joomla_article

  def create_permitted?
    return true if acting_user.administrator?
    return false unless portfolio
    portfolio.chair?(acting_user) || conference.chair?(acting_user)
  end

  def update_permitted?
    return false if portfolio_id_changed?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def destroy_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
