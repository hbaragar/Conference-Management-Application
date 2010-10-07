class Member < ActiveRecord::Base

  include MyHtml

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

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :portfolio_id

  def before_validation_on_create
    if user
      self.name = user.name unless user && user[/\w/]
      self.private_email_address = user.email_address unless private_email_address && private_email_address[/@/]
      if other_member = user.members.first
	self.affiliation = other_member.affiliation unless affiliation && affiliation[/\w/]
	self.country = other_member.country unless country && country[/\w/]
      end
    end
  end

  def validate
    errors.add(:user_id, "cannot be changed after being set") if user_id && user_id_was && user_id_changed?
    if user && user.reload && private_email_address != user.email_address
      errors.add(:private_email_address, "can't change to another user") if User.find_by_email_address(private_email_address)
    end
  end

  def before_save
    if private_email_address_changed?
      if user
	self.user = nil unless private_email_address && private_email_address[/@/]
     else
	self.user = User.find_by_email_address(private_email_address)
      end
    end
    self.name = html_encode_non_ascii_characters(name)
    self.affiliation = html_encode_non_ascii_characters(affiliation)
    self.country = html_encode_non_ascii_characters(country)
  end

  def after_save
    if user && (user.name != name || user.email_address != private_email_address)
      user.update_attributes(:name => name, :email_address => private_email_address)
    end
    portfolio.cfp.changes_pending! if portfolio.cfp
  end


  def conference
    portfolio.conference
  end

  def to_html chairs_starred = nil
    html = name
    if chair && (portfolio.public_email_address =~ /@/ rescue false)
      html = email_link(html, portfolio.public_email_address)
    end
    html += "*" if chair && chairs_starred
    html
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
