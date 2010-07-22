class Involvement < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  belongs_to :participant
  belongs_to :presentation

  fields do
    role :string
    timestamps
  end

  def to_html
    [span("role", role), participant.to_html]
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.portfolio_chair?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
