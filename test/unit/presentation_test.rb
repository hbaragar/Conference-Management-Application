require File.dirname(__FILE__) + '/../test_helper'

class PresentationTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_presentation = presentations(:a_presentation)
    @a_portfolio = @a_presentation.portfolio
  end

  def test_associations
    assert_equal 1, @a_presentation.involvements.count
    assert_equal 1, @a_presentation.participants.count
  end

  def test_create_permissions
    new_presentation = @a_portfolio.presentations.new :title => "Another Important Result"
    assert new_presentation.creatable_by?(users(:administrator))
    assert new_presentation.creatable_by?(users(:general_chair))
    assert new_presentation.creatable_by?(users(:a_portfolio_chair))
    assert !new_presentation.creatable_by?(users(:a_portfolio_member))
    assert !new_presentation.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_presentation.updatable_by?(users(:administrator))
    assert @a_presentation.updatable_by?(users(:general_chair))
    assert @a_presentation.updatable_by?(users(:a_portfolio_chair))
    assert !@a_presentation.updatable_by?(users(:another_conference_chair))
    assert !@a_presentation.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_presentation.destroyable_by?(users(:administrator))
    assert @a_presentation.destroyable_by?(users(:general_chair))
    assert @a_presentation.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_presentation.destroyable_by?(users(:a_portfolio_member))
    assert !@a_presentation.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
