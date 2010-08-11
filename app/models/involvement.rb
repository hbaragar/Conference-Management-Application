class Involvement < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :participant
  belongs_to :presentation

  has_many :sessions, :through => :presentation

  fields do
    role :string
    timestamps
  end

  def before_save
    self.role = html_encode_non_ascii_characters(role)
  end

  def to_html
    div("participant",
      (span("role", role) unless role == "author"),
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
