class Portfolio < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name        :string, :required
    email_address :email_address
    description :markdown
  end

  has_many :members, :dependent => :destroy


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
