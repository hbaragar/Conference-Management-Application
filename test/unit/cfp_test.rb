require File.dirname(__FILE__) + '/../test_helper'

class CfpTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
    @a_cfp = calls(:a_cfp)
  end

  def test_after_save
    assert_equal "published", @a_cfp.state
    @a_cfp.due_on = '2010-04-04'
    @a_cfp.save
    @a_cfp.reload
    assert_equal "changes_pending", @a_cfp.state
    @a_cfp.state = 'published'
    @a_cfp.save
    @a_cfp.reload
    @a_cfp.details = 'changes'
    @a_cfp.save
    @a_cfp.reload
    assert_equal "changes_pending", @a_cfp.state
    @a_cfp.state = 'published'
    @a_cfp.save
    @a_cfp.reload
    assert_equal "published", @a_cfp.state
    @a_cfp.details = 'more changes'
    @a_cfp.state = 'unpublished'
    @a_cfp.save
    @a_cfp.reload
    assert_equal "unpublished", @a_cfp.state
  end

  def test_create_permissions
    new_cfp = @a_portfolio.cfps.new :due_on => 1.months.from_now
    assert new_cfp.creatable_by?(users(:administrator))
    assert new_cfp.creatable_by?(users(:general_chair))
    assert new_cfp.creatable_by?(users(:a_portfolio_chair))
    assert !new_cfp.creatable_by?(users(:a_portfolio_member))
    assert !new_cfp.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_cfp.updatable_by?(users(:administrator))
    assert @a_cfp.updatable_by?(users(:general_chair))
    assert @a_cfp.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_member))
    @a_cfp.portfolio = portfolios(:a_conference_general)
    assert !@a_cfp.updatable_by?(users(:administrator))
    assert !@a_cfp.updatable_by?(users(:general_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_cfp.destroyable_by?(users(:administrator))
    assert @a_cfp.destroyable_by?(users(:general_chair))
    assert @a_cfp.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.destroyable_by?(users(:a_portfolio_member))
    assert !@a_cfp.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
