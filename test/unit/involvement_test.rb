require File.dirname(__FILE__) + '/../test_helper'

class InvolvementTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_involvement = involvements(:a_involvement)
  end

  def test_create_permissions
    new_involvement = Participant.new :name => "Another Author"
    assert new_involvement.creatable_by?(users(:administrator))
    assert new_involvement.creatable_by?(users(:general_chair))
    assert new_involvement.creatable_by?(users(:a_portfolio_chair))
    assert new_involvement.creatable_by?(users(:another_conference_chair))
    assert !new_involvement.creatable_by?(users(:a_portfolio_member))
  end

  def test_update_permissions
    assert @a_involvement.updatable_by?(users(:administrator))
    assert @a_involvement.updatable_by?(users(:general_chair))
    assert @a_involvement.updatable_by?(users(:a_portfolio_chair))
    assert @a_involvement.updatable_by?(users(:another_conference_chair))
    assert !@a_involvement.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_involvement.destroyable_by?(users(:administrator))
    assert @a_involvement.destroyable_by?(users(:general_chair))
    assert @a_involvement.destroyable_by?(users(:a_portfolio_chair))
    assert @a_involvement.destroyable_by?(users(:another_conference_chair))
    assert !@a_involvement.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end