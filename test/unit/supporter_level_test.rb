require File.dirname(__FILE__) + '/../test_helper'

class SupporterLevelTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @the_supporter_portfolio = portfolios(:the_supporter_portfolio)
    @a_call_for_supporter = @the_supporter_portfolio.call_for_supporters.create
    @a_supporter_level = @a_call_for_supporter.supporter_levels.create(
      :name		=> "gold",
      :minimum_donation	=> 10000,
      :description	=> "A good supporter is a gold supporter"
    )
  end

  def test_after_save
    @a_call_for_supporter.reload
    assert_equal 'changes_pending', @a_call_for_supporter.state
    @a_call_for_supporter.state = 'published'
    @a_call_for_supporter.save
    @a_call_for_supporter.reload
    assert_equal 'published', @a_call_for_supporter.state
    @a_supporter_level.name = 'Changed name'
    @a_supporter_level.save
    @a_call_for_supporter = @a_supporter_level.call_for_supporter
    assert_equal 'changes_pending', @a_call_for_supporter.state
  end

  def test_create_permissions
    new_supporter_level = @a_call_for_supporter.supporter_levels.new 
    assert new_supporter_level.creatable_by?(users(:administrator))
    assert new_supporter_level.creatable_by?(users(:general_chair))
    assert new_supporter_level.creatable_by?(users(:the_supporter_portfolio_chair))
    assert !new_supporter_level.creatable_by?(users(:a_supporter_portfolio_member))
    assert !new_supporter_level.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_supporter_level.updatable_by?(users(:administrator))
    assert @a_supporter_level.updatable_by?(users(:general_chair))
    assert @a_supporter_level.updatable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_supporter_level.updatable_by?(users(:another_conference_chair))
    assert !@a_supporter_level.updatable_by?(users(:a_supporter_portfolio_member))
    @a_supporter_level.call_for_supporter_id = nil
    assert !@a_supporter_level.updatable_by?(users(:administrator))
    assert !@a_supporter_level.updatable_by?(users(:general_chair))
    assert !@a_supporter_level.updatable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_supporter_level.updatable_by?(users(:another_conference_chair))
    assert !@a_supporter_level.updatable_by?(users(:a_supporter_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_supporter_level.destroyable_by?(users(:administrator))
    assert @a_supporter_level.destroyable_by?(users(:general_chair))
    assert @a_supporter_level.destroyable_by?(users(:the_supporter_portfolio_chair))
    assert !@a_supporter_level.destroyable_by?(users(:a_supporter_portfolio_member))
    assert !@a_supporter_level.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
