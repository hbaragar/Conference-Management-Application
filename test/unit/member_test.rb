require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase


  def setup
    @member = members(:a_portfolio_member)
    @a_portfolio_chair = members(:a_portfolio_chair)
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
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
