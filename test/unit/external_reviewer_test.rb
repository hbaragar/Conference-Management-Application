require File.dirname(__FILE__) + '/../test_helper'

class ExternalReviewerTest < ActiveSupport::TestCase

  def setup
    @external_reviewer = external_reviewers(:an_external_reviewer)
    @a_cfp = calls(:a_cfp)
  end

  def test_validation
    existing_external_reviewer = @a_cfp.external_reviewers.create(
      :name => "Rob Pike",
      :private_email_address => "rob.pike@google.com"
    )
    assert !existing_external_reviewer.valid?
  end

  def test_create_permissions
    new_external_reviewer = ExternalReviewer.new :cfp => @a_cfp, :name => "A new external_reviewer"
    assert new_external_reviewer.creatable_by?(users(:administrator))
    assert new_external_reviewer.creatable_by?(users(:general_chair))
    assert new_external_reviewer.creatable_by?(users(:a_portfolio_chair))
    assert !new_external_reviewer.creatable_by?(users(:a_portfolio_member))
    assert !new_external_reviewer.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @external_reviewer.updatable_by?(users(:administrator))
    assert @external_reviewer.updatable_by?(users(:general_chair))
    assert @external_reviewer.updatable_by?(users(:a_portfolio_chair))
    assert !@external_reviewer.updatable_by?(users(:a_portfolio_member))
    assert !@external_reviewer.updatable_by?(users(:another_conference_chair))

    #assert @external_reviewer.updatable_by?(users(:administrator))
    #assert !@external_reviewer.updatable_by?(users(:general_chair))
    #assert !@external_reviewer.updatable_by?(users(:a_portfolio_chair))
    #assert !@external_reviewer.updatable_by?(users(:a_portfolio_member))
    #assert !@external_reviewer.updatable_by?(users(:another_conference_chair))
  end

  def test_destroy_permissions
    assert @external_reviewer.destroyable_by?(users(:administrator))
    assert @external_reviewer.destroyable_by?(users(:general_chair))
    assert @external_reviewer.destroyable_by?(users(:a_portfolio_chair))
    assert !@external_reviewer.destroyable_by?(users(:a_portfolio_member))
    assert !@external_reviewer.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
