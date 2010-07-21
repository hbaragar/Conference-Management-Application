class Participant < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name                  :string, :required, :unique
    affiliation           :string
    private_email_address :email_address
    bio                   :markdown
    timestamps
  end

  has_many :involvements, :dependent => :destroy
  has_many :presentations, :through => :involvements

  default_scope :order => :name


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
