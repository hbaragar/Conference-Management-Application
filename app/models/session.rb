class Session < ActiveRecord::Base

  DEFAULT_NAME = "To Be Scheduled".freeze

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    name      :string, :required, :default => DEFAULT_NAME
    starts_at :datetime, :required, :default => '2010-10-22 08:00'
    ends_at   :datetime, :required, :default => '2010-10-22 09:00'
    timestamps
  end

  belongs_to :joomla_article

  has_many :presentations

  def conference
    portfolio.conference
  end

  def multiple_presentations?
    portfolio.session_type == "multiple_presentations"
  end

  def to_html
    div("session",
      coordinates_to_html,
      presentations.collect {|p| p.to_html}
   )
  end

  def coordinates_to_html
    div("coordinates",
      "Co-ordinates TBA"
    )
  end


  # --- Permissions --- #

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