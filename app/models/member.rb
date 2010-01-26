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

  default_scope :order => 'chair DESC, name'

  def after_create
    if existing_user = User.find_by_email_address(email_address)
      self.user = existing_user
      save
    end
  end

  def after_update
    return unless user && user.email_address != email_address
    user.email_address = email_address
    user.save
  end

  def after_save
    Member.find_all_by_email_address(email_address).each do |m|
      if m.name != name
	m.name = name
	m.save
      end
      if m.affiliation != affiliation
	m.affiliation = affiliation
	m.save
      end
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
