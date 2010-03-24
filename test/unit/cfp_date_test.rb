require File.dirname(__FILE__) + '/../test_helper'

class CfpDateTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
    @a_cfp = @a_portfolio.cfps.create :due_on => 1.months.from_now
    @a_cfp_date = @a_cfp.other_dates.create :label => "New due date", :due_on => 2.weeks.from_now
  end

  def test_after_save
    @a_cfp.reload
    assert_equal 'changes_pending', @a_cfp.state
    @a_cfp.state = 'published'
    @a_cfp.save
    @a_cfp.reload
    assert_equal 'published', @a_cfp.state
    @a_cfp_date.label = 'Changed due date'
    @a_cfp_date.save
    @a_cfp = @a_cfp_date.cfp
    assert_equal 'changes_pending', @a_cfp.state
  end

  def test_cfp_other_dates
    assert_equal 2+1, @a_cfp.other_dates.count
    assert_equal @a_cfp_date, @a_cfp.other_dates.first
  end

  def test_create_permissions
    new_cfp_date = CfpDate.new :cfp => @a_cfp, :label => "Another date", :due_on => 3.months.from_now
    assert new_cfp_date.creatable_by?(users(:administrator))
    assert new_cfp_date.creatable_by?(users(:general_chair))
    assert new_cfp_date.creatable_by?(users(:a_portfolio_chair))
    assert !new_cfp_date.creatable_by?(users(:a_portfolio_member))
    assert !new_cfp_date.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_cfp_date.updatable_by?(users(:administrator))
    assert @a_cfp_date.updatable_by?(users(:general_chair))
    assert @a_cfp_date.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp_date.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp_date.updatable_by?(users(:a_portfolio_member))
    @a_cfp_date.cfp_id = @a_cfp_date.cfp_id + 1
    assert !@a_cfp_date.updatable_by?(users(:administrator))
    assert !@a_cfp_date.updatable_by?(users(:general_chair))
    assert !@a_cfp_date.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp_date.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp_date.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_cfp_date.destroyable_by?(users(:administrator))
    assert @a_cfp_date.destroyable_by?(users(:general_chair))
    assert @a_cfp_date.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_cfp_date.destroyable_by?(users(:a_portfolio_member))
    assert !@a_cfp_date.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
