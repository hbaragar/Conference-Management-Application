class Room < ActiveRecord::Base

  include MyHtml

  hobo_model # Don't put anything above this

  fields do
    name       :string
    capacity   :string
    door_count :integer
    short_name :string
    timestamps
  end

  belongs_to :facility_area

  has_many :sessions

  default_scope :order => :name

  validates_uniqueness_of :name, :scope => :facility_area_id

  def to_s
    name
  end


  def before_save
    self.room = html_encode_non_ascii_characters(room)
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
