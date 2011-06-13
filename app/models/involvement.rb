class Involvement < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :participant
  belongs_to :presentation

  has_many :sessions, :through => :presentation

  def portfolios
    sessions.*.portfolio
  end

  fields do
    role :string
    timestamps
  end

  validates_presence_of :participant_id
  validates_presence_of :presentation_id

  def conference
    participant && participant.conference || presentation && presentation.conference
  end

  def hosting_conference
    conference.hosting_conference
  end

  def name
    role
  end

  def before_save
    self.role = html_encode_non_ascii_characters(role)
  end

  def after_save
    portfolios.*.changes_pending!
  end

  def to_html
    div("participant",
      (span("role", role.to_html) unless role == "author"),
       participant && participant.to_html
    )
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def update_permitted?
    return false if presentation_id_changed?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
