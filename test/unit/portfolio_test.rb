require File.dirname(__FILE__) + '/../test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @general = portfolios(:a_conference_general)
    @a_portfolio = portfolios(:a_portfolio)
  end

  def test_members
    assert_equal 1, @general.members.count
  end

  def test_cfps
    assert_equal 1, @a_portfolio.cfps.count
  end

  def test_create_permissions
    new_portfolio = Portfolio.new :conference => @a_conference, :name => "New Portfolio"
    assert new_portfolio.creatable_by?(users(:administrator))
    assert new_portfolio.creatable_by?(users(:general_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_member))
    assert !new_portfolio.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert @a_portfolio.updatable_by?(users(:general_chair))
    assert @a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:another_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
    @general.name = 'Not allowed'
    assert !@general.updatable_by?(users(:administrator))
    assert !@general.updatable_by?(users(:general_chair))
    assert !@general.updatable_by?(users(:a_portfolio_chair))
    assert !@general.updatable_by?(users(:another_conference_chair))
    assert !@general.updatable_by?(users(:a_portfolio_member))
    @a_portfolio.conference = conferences(:another_conference)
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert !@a_portfolio.updatable_by?(users(:general_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:another_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert !@a_portfolio.destroyable_by?(users(:administrator))
    assert !@a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:another_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @a_portfolio.members.clear
    assert @a_portfolio.destroyable_by?(users(:administrator))
    assert @a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:another_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @general.members.clear
    assert !@general.destroyable_by?(users(:administrator))
    assert !@general.destroyable_by?(users(:general_chair))
    assert !@general.destroyable_by?(users(:another_conference_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
