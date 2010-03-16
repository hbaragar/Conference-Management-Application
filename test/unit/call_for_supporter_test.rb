require File.dirname(__FILE__) + '/../test_helper'

class CallForSupporterTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @the_supporter_portfolio = portfolios(:the_supporter_portfolio)
    @a_call_for_supporter = @the_supporter_portfolio.call_for_supporters.create
  end

  def test_create_permissions
    new_call_for_supporter = @the_supporter_portfolio.call_for_supporters.new 
    assert new_call_for_supporter.creatable_by?(users(:administrator))
    assert new_call_for_supporter.creatable_by?(users(:general_chair))
    assert new_call_for_supporter.creatable_by?(users(:the_supporter_portfolio_chair))
    assert !new_call_for_supporter.creatable_by?(users(:a_supporter_portfolio_member))
    assert !new_call_for_supporter.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_call_for_supporter.updatable_by?(users(:administrator))
    assert @a_call_for_supporter.updatable_by?(users(:general_chair))
    assert @a_call_for_supporter.updatable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_call_for_supporter.updatable_by?(users(:another_conference_chair))
    assert !@a_call_for_supporter.updatable_by?(users(:a_supporter_portfolio_member))
    @a_call_for_supporter.portfolio = portfolios(:a_conference_general)
    assert !@a_call_for_supporter.updatable_by?(users(:administrator))
    assert !@a_call_for_supporter.updatable_by?(users(:general_chair))
    assert !@a_call_for_supporter.updatable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_call_for_supporter.updatable_by?(users(:another_conference_chair))
    assert !@a_call_for_supporter.updatable_by?(users(:a_supporter_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_call_for_supporter.destroyable_by?(users(:administrator))
    assert @a_call_for_supporter.destroyable_by?(users(:general_chair))
    assert @a_call_for_supporter.destroyable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_call_for_supporter.destroyable_by?(users(:a_supporter_portfolio_member))
    assert !@a_call_for_supporter.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
