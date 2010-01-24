class Member < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    chair       :boolean, :default => false
    name        :string, :required
    affiliation :string
    email_address :email_address
  end

  belongs_to :user


  def conference
    portfolio.conference
  end


  # --- Permissions --- #

  def create_permitted?
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def update_permitted?
    (portfolio.chair?(acting_user) && none_changed?(:chair)) ||
      conference.chair?(acting_user) ||
      acting_user.administrator?
  end

  def destroy_permitted?
    return false if acting_user == user
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
