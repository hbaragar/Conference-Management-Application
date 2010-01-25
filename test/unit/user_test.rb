require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_user_propagate_to_members
    user = User.create(
      :name => "Gregor Kiczales",
      :email_address => "gk@ubc.ca"
    )
    assert_equal user, members(:another_portfolio_member).user
  end

  def test_email_address_propagate
    user = users(:a_portfolio_member)
    assert_equal "gl@ucf.edu", user.email_address
    user.email_address = "gl@new.edu"
    user.save
    user.members.each do |m|
      assert_equal user.email_address, m.email_address
    end
    (Member.all - user.members).each do |m|
      assert_not_equal user.email_address, m.email_address
    end
  end

end
