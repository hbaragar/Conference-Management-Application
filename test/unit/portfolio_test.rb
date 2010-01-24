require File.dirname(__FILE__) + '/../test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def setup
    @splash = conferences(:splash)
    @general = portfolios(:splash_general)
    @oopsla = portfolios(:splash_oopsla)
  end

  def test_members
    portfolio = portfolios(:splash_general)
    assert_equal 1, portfolio.members.count
  end

  def test_create_permissions
    new_portfolio = Portfolio.new :conference => @splash, :name => "New Portfolio"
    assert new_portfolio.creatable_by?(users(:administrator))
    assert new_portfolio.creatable_by?(users(:splash_chair))
    assert !new_portfolio.creatable_by?(users(:oopsla_chair))
    assert !new_portfolio.creatable_by?(users(:oopsla_member))
    assert !new_portfolio.creatable_by?(users(:onward_chair))
  end

  def test_update_permissions
    assert @oopsla.updatable_by?(users(:administrator))
    assert @oopsla.updatable_by?(users(:splash_chair))
    assert @oopsla.updatable_by?(users(:oopsla_chair))
    assert !@oopsla.updatable_by?(users(:onward_chair))
    assert !@oopsla.updatable_by?(users(:oopsla_member))
  end

  def test_destroy_permissions
    assert !@oopsla.destroyable_by?(users(:administrator))
    assert !@oopsla.destroyable_by?(users(:splash_chair))
    assert !@oopsla.destroyable_by?(users(:onward_chair))
    assert !@oopsla.destroyable_by?(users(:oopsla_chair))
    assert !@oopsla.destroyable_by?(users(:oopsla_member))
    @oopsla.members.clear
    assert @oopsla.destroyable_by?(users(:administrator))
    assert @oopsla.destroyable_by?(users(:splash_chair))
    assert !@oopsla.destroyable_by?(users(:onward_chair))
    assert !@oopsla.destroyable_by?(users(:oopsla_chair))
    assert !@oopsla.destroyable_by?(users(:oopsla_member))
    @general.members.clear
    assert !@general.destroyable_by?(users(:administrator))
    assert !@general.destroyable_by?(users(:splash_chair))
    assert !@general.destroyable_by?(users(:onward_chair))
    assert !@general.destroyable_by?(users(:oopsla_chair))
    assert !@general.destroyable_by?(users(:oopsla_member))
  end

  def test_view_permissions
  end

end
