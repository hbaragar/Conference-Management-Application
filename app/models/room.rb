class Room < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name       :string
    capacity   :string
    area       :string
    short_name :string
    timestamps
  end

  has_many :sessions


  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
