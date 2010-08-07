require File.dirname(__FILE__) + '/../test_helper'

class ParticipantTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_participant = participants(:a_participant)
    @b_participant = participants(:b_participant)
  end

  def test_associations
    assert_equal 2, @a_participant.involvements.count
    assert_equal 2, @a_participant.presentations.count
  end

  def test_session_conflicts
    assert_equal [], @b_participant.session_conflicts
    assert_equal [[sessions(:a_session),sessions(:b_session)]], @a_participant.session_conflicts
  end

  def test_validations
    new_participant = conferences(:another_conference).participants.new :name => "Another Author"
    assert !new_participant.valid?
  end

  def test_create_permissions
    new_participant = @a_conference.participants.new :name => "Another Author"
    assert new_participant.creatable_by?(users(:administrator))
    assert new_participant.creatable_by?(users(:general_chair))
    assert new_participant.creatable_by?(users(:a_portfolio_chair))
    assert new_participant.creatable_by?(users(:another_conference_chair))
    assert !new_participant.creatable_by?(users(:a_portfolio_member))
  end

  def test_update_permissions
    assert @a_participant.updatable_by?(users(:administrator))
    assert @a_participant.updatable_by?(users(:general_chair))
    assert @a_participant.updatable_by?(users(:a_portfolio_chair))
    assert @a_participant.updatable_by?(users(:another_conference_chair))
    assert !@a_participant.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_participant.destroyable_by?(users(:administrator))
    assert @a_participant.destroyable_by?(users(:general_chair))
    assert @a_participant.destroyable_by?(users(:a_portfolio_chair))
    assert @a_participant.destroyable_by?(users(:another_conference_chair))
    assert !@a_participant.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
