require File.dirname(__FILE__) + '/../test_helper'

class ConferenceTest < ActiveSupport::TestCase

  def setup
    @splash = conferences(:splash)
    @onward = conferences(:onward)
  end

  def test_fields
    assert_equal "Splash 2010", @splash.name
    assert_equal "Onward! 2010", @onward.name
    assert_equal "Splash 2010", @onward.colocated_with.name
    assert_equal 1, @splash.colocated_conferences.size
    assert_equal "Onward! 2010", @splash.colocated_conferences.first.name
  end

  def test_portfolios
    assert_equal 2, @splash.portfolios.count
    assert_equal 1, @onward.portfolios.count
    assert_equal "General", @onward.portfolios.first.name
  end

  def test_chair
    assert @splash.chair?(users(:splash_chair))
    assert !@splash.chair?(users(:oopsla_chair))
    assert !@splash.chair?(users(:oopsla_member))
    assert !@splash.chair?(users(:onward_chair))
  end

  def test_create_permissions
  end

  def test_update_permissions
    assert @splash.updatable_by?(users(:administrator))
    assert @splash.updatable_by?(users(:splash_chair))
    assert !@splash.updatable_by?(users(:onward_chair))
    assert @onward.updatable_by?(users(:onward_chair))
    assert !@onward.updatable_by?(users(:splash_chair))
    assert !@splash.updatable_by?(users(:oopsla_chair))
    assert !@splash.updatable_by?(users(:oopsla_member))
    @splash.colocated_with_id = 5
    assert @splash.updatable_by?(users(:administrator))
    assert !@splash.updatable_by?(users(:splash_chair))
  end

  def test_destroy_permissions
    assert !@splash.destroyable_by?(users(:administrator))
    assert !@splash.destroyable_by?(users(:splash_chair))
    assert !@splash.destroyable_by?(users(:oopsla_chair))
    assert !@splash.destroyable_by?(users(:oopsla_member))
    @splash.portfolios.clear
    assert @splash.destroyable_by?(users(:administrator))
  end

  def test_view_permissions
  end

end
