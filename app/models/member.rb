class Member < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    chair       :boolean, :default => false
    name        :string, :required
    affiliation :string
    country	:string
    private_email_address :email_address
  end

  belongs_to :user

  default_scope :order => 'chair DESC, name'

  validates_uniqueness_of :name, :scope => :portfolio_id

  def before_validation_on_create
    if user && other_member = user.members.first
      self.name ||= other_member.name
      self.private_email_address ||= other_member.private_email_address
      self.affiliation ||= other_member.affiliation
      self.country ||= other_member.country
    end
  end

  def before_save
    if private_email_address_changed? && !user
      self.user = User.find_by_email_address(private_email_address)
    end
  end

  def after_save
    if user && (user.name != name || user.email_address != private_email_address)
      user.email_address = private_email_address
      user.name = name
      user.save
    end
  end


  def conference
    portfolio.conference
  end


  # --- Permissions --- #

  def create_permitted?
    return true if acting_user.administrator?
    portfolio && (portfolio.chair?(acting_user) || conference.chair?(acting_user))
  end

  def update_permitted?
    (portfolio.chair?(acting_user) && none_changed?(:chair, :user_id)) ||
      (conference.chair?(acting_user) && none_changed?(:user_id)) ||
      acting_user.administrator?
  end

  def destroy_permitted?
    return false if acting_user == user
    portfolio.chair?(acting_user) || conference.chair?(acting_user) || acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
