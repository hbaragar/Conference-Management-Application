require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase


  def setup
    @member = members(:a_portfolio_member)
    @a_portfolio_chair = members(:a_portfolio_chair)
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
  end

  def test_validation
    existing_member = @a_portfolio.members.create(
      :name => "Gary Leavens",
      :private_email_address => "gl@ucf.edu"
    )
    assert !existing_member.valid?
  end

  test "auto fill from user" do
    existing_user = users(:a_portfolio_member)
    assert new_member = portfolios(:another_portfolio).members.create(:user => existing_user)
    assert_equal "Gary Leavens", new_member.name
    assert_equal "gl@ucf.edu", new_member.private_email_address
    assert_equal "University of Central Florida", new_member.affiliation
    assert_equal "USA", new_member.country
    assert new_member = portfolios(:yet_another_portfolio).members.create(
      :user => existing_user,
      :name => "Gary T. Leavens"
    )
    #assert_equal "Gary T. Leavens", new_member.name
    #assert_equal "gl@ucf.edu", new_member.private_email_address
    #assert_equal "University of Central Florida", new_member.affiliation
    #assert_equal "USA", new_member.country
  end

  test "auto assign the user on create" do
    new_member = portfolios(:another_portfolio).members.create(
      :name => "Gary Leavens",
      :private_email_address => "gl@ucf.edu"
    )
    existing_user = new_member.user
    assert existing_user
    assert_equal "Gary Leavens", existing_user.name
    new_member = portfolios(:yet_another_portfolio).members.create(
      :name => "Gary T. Leavens",
      :private_email_address => "gl@ucf.edu"
    )
    existing_user = new_member.user
    assert existing_user
    assert_equal "Gary T. Leavens", existing_user.name
    another_new_member = @a_portfolio.members.create(
      :name => "A Member",
      :private_email_address => "am@some.edu"
    )
    assert !another_new_member.user
  end

  test "auto assign the user on update" do
    new_member = portfolios(:another_portfolio).members.create(
      :name => "Gary T. Leavens"
    )
    assert !new_member.user
    existing_user = users(:a_portfolio_member)
    assert_equal "Gary Leavens", existing_user.name
    new_member.private_email_address = existing_user.email_address
    new_member.save
    assert_equal existing_user, new_member.user
    assert_equal "Gary T. Leavens", new_member.user.name
  end

  test "test email propagation to user" do
    user = users(:a_portfolio_member)
    assert_equal "gl@ucf.edu", user.email_address
    @member.private_email_address = "gl@new.edu"
    assert @member.save
    user.reload
    assert_equal "gl@new.edu", user.email_address
    somebody = @a_portfolio.members.create(:name => 'Somebody')
    @a_portfolio.members.create(:name => 'Another body')
    somebody.reload
    assert_equal 'Somebody', somebody.name
  end

  test "re/un-assigning user when email is changed" do
    assert @member.user
    @member.private_email_address = ""
    assert @member.save
    @member.reload
    assert !@member.user
  end

  test "cannot change email address to that of a different user" do
    @member.private_email_address = @a_portfolio_chair.private_email_address
    assert @member.user
    assert !@member.valid?
  end

  def no_test_synchronize_names_and_affliations_and_countries
    new_member = @a_portfolio.members.create(
      :name => "Gary T. Leavens",
      :affiliation => "UCF",
      :private_email_address => "gl@ucf.edu"
    )
    @member.reload
    assert_equal "Gary T. Leavens", @member.name
    assert_equal "UCF", @member.affiliation
    assert_nil @member.country
    @member.name = "Gary Leavens"
    @member.affiliation = "University of Central Florida"
    @member.country = "USA"
    @member.save
    new_member.reload
    assert_equal "Gary Leavens", new_member.name
    assert_equal "University of Central Florida", new_member.affiliation
    assert_equal "USA", new_member.country
  end

  def test_create_permissions
    new_member = Member.new :portfolio => @a_portfolio, :name => "A new member"
    assert new_member.creatable_by?(users(:administrator))
    assert new_member.creatable_by?(users(:general_chair))
    assert new_member.creatable_by?(users(:a_portfolio_chair))
    assert !new_member.creatable_by?(users(:a_portfolio_member))
    assert !new_member.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @member.updatable_by?(users(:administrator))
    assert @member.updatable_by?(users(:general_chair))
    assert @member.updatable_by?(users(:a_portfolio_chair))
    assert !@member.updatable_by?(users(:a_portfolio_member))
    assert !@member.updatable_by?(users(:another_conference_chair))
    assert @a_portfolio_chair.updatable_by?(users(:administrator))
    assert @a_portfolio_chair.updatable_by?(users(:general_chair))
    assert @a_portfolio_chair.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio_chair.updatable_by?(users(:a_portfolio_member))
    assert !@a_portfolio_chair.updatable_by?(users(:another_conference_chair))
    @a_portfolio_chair.chair = false
    assert @a_portfolio_chair.updatable_by?(users(:administrator))
    assert @a_portfolio_chair.updatable_by?(users(:general_chair))
    assert !@a_portfolio_chair.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio_chair.updatable_by?(users(:a_portfolio_member))
    assert !@a_portfolio_chair.updatable_by?(users(:another_conference_chair))
    @member.user_id = 1
    assert @member.updatable_by?(users(:administrator))
    assert !@member.updatable_by?(users(:general_chair))
    assert !@member.updatable_by?(users(:a_portfolio_chair))
    assert !@member.updatable_by?(users(:a_portfolio_member))
    assert !@member.updatable_by?(users(:another_conference_chair))
  end

  def test_destroy_permissions
    assert @member.destroyable_by?(users(:administrator))
    assert @member.destroyable_by?(users(:general_chair))
    assert @member.destroyable_by?(users(:a_portfolio_chair))
    assert !@member.destroyable_by?(users(:a_portfolio_member))
    assert !@member.destroyable_by?(users(:another_conference_chair))
    assert @a_portfolio_chair.destroyable_by?(users(:administrator))
    assert @a_portfolio_chair.destroyable_by?(users(:general_chair))
    assert !@a_portfolio_chair.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio_chair.destroyable_by?(users(:a_portfolio_member))
    assert !@a_portfolio_chair.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
