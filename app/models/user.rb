class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    timestamps
  end

  has_many :members

  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
  before_create { |user| user.administrator = true if !Rails.env.test? && count == 0 }

  def validate
    if new_record?
      errors.add(:email_address, "not recognized") unless
	User.count == 0 || Member.find_by_private_email_address(email_address)
    end
  end

  def after_create
    Member.find_all_by_private_email_address(email_address).each do |m|
      m.update_attributes(:name => name, :user => self)
    end
  end

  def after_save
    if any_changed?(:name, :email_address)
      members.each do |m|
	m.update_attributes(:name => name, :private_email_address => email_address)
      end
    end
  end


  def portfolio_chair?
    members.detect {|m| m.chair?}
  end

  
  # --- Signup lifecycle --- #

  lifecycle do

    state :inactive, :default => true
    state :active

    create :signup, :available_to => "Guest",
           :params => [:name, :email_address, :password, :password_confirmation],
           :become => :inactive, :new_key => true do
	     UserMailer.deliver_activation(self, lifecycle.key) unless email_address.blank?
	   end

    transition :activate, { :inactive => :active }, :available_to => :key_holder

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :request_password_reset, { :inactive => :active }, :new_key => true do
      UserMailer.deliver_activation(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end
  

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    acting_user.administrator? || 
      (acting_user == self && only_changed?(:email_address, :crypted_password,
                                            :current_password, :password, :password_confirmation))
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
