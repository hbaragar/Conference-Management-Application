class FacilityArea < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :conference

  fields do
    name :string
    timestamps
  end

  belongs_to :joomla_article

  has_many :rooms, :dependent => :destroy

  default_scope :order => :name

  validates_uniqueness_of :name, :scope => :conference_id


  # --- Permissions --- #

  never_show :joomla_article

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
