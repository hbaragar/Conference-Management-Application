require File.dirname(__FILE__) + '/../test_helper'

class InvolvementTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_involvement = involvements(:a_involvement)
    @a_participant = participants(:a_participant)
  end

  def test_validations
    invalid = Involvement.new
    assert invalid.invalid?
    assert invalid.errors[:participant_id]
    assert invalid.errors[:presentation_id]
    assert @a_involvement.valid?
  end

  def test_portfolio_lifecycle
    @a_involvement.role = "Name Change"
    assert @a_involvement.save
    assert @a_involvement.portfolios.first.changes_pending?
  end
  
  def test_defaults
    an_involvement = presentations(:a_workshop_presentation).involvements.new
    assert_equal "workshop leader", an_involvement.role
  end

  def test_autocreate_new_participants_for_conference_next_year
    count = Participant.count
    a_presentation_next_year = presentations(:a_presentation_next_year)
    an_involvement_next_year = a_presentation_next_year.involvements.new(
      "participant"	=> "An Unknown Participant"
    )
    assert_equal 1+count, Participant.count
    assert an_involvement_next_year.valid?
    an_involvement_next_year = a_presentation_next_year.involvements.new(
      :participant_id	=> @a_participant.id
    )
    assert_equal 2+count, Participant.count
    a_participant_next_year = an_involvement_next_year.participant
    assert_not_equal @a_participant.id, a_participant_next_year.id
    assert_equal conferences(:a_conference_next_year).id, a_participant_next_year.conference_id
  end

  def test_create_permissions
    new_involvement = Participant.new :name => "Another Author"
    assert new_involvement.creatable_by?(users(:administrator))
    assert new_involvement.creatable_by?(users(:general_chair))
    assert new_involvement.creatable_by?(users(:a_portfolio_chair))
    assert new_involvement.creatable_by?(users(:a_colocated_conference_chair))
    assert !new_involvement.creatable_by?(users(:a_portfolio_member))
  end

  def test_update_permissions
    assert @a_involvement.updatable_by?(users(:administrator))
    assert @a_involvement.updatable_by?(users(:general_chair))
    assert @a_involvement.updatable_by?(users(:a_portfolio_chair))
    assert @a_involvement.updatable_by?(users(:a_colocated_conference_chair))
    assert !@a_involvement.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_involvement.destroyable_by?(users(:administrator))
    assert @a_involvement.destroyable_by?(users(:general_chair))
    assert @a_involvement.destroyable_by?(users(:a_portfolio_chair))
    assert @a_involvement.destroyable_by?(users(:a_colocated_conference_chair))
    assert !@a_involvement.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
