class Portfolio < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name        :string, :required
    description :markdown
  end


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
