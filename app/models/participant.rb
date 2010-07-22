class Participant < ActiveRecord::Base

  include MyHtml

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


  def to_html
    [span("name", name), span("affiliation",affiliation)]
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
