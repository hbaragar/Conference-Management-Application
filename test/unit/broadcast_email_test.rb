require File.dirname(__FILE__) + '/../test_helper'

class BroadcastEmailTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
    @a_cfp = @a_portfolio.cfps.create :due_on => 1.months.from_now
    @a_broadcast_email = @a_cfp.broadcast_emails.create :address => "software@mailing.list"
  end

  def test_cfp_broadcast_emails
    assert_equal 1, @a_cfp.broadcast_emails.count
    assert_equal @a_broadcast_email, @a_cfp.broadcast_emails.first
  end

  def test_create_permissions
    new_broadcast_email = @a_cfp.broadcast_emails.new :address => "software@mailing.list"
    assert new_broadcast_email.creatable_by?(users(:administrator))
    assert new_broadcast_email.creatable_by?(users(:general_chair))
    assert new_broadcast_email.creatable_by?(users(:a_portfolio_chair))
    assert !new_broadcast_email.creatable_by?(users(:a_portfolio_member))
    assert !new_broadcast_email.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_broadcast_email.updatable_by?(users(:administrator))
    assert @a_broadcast_email.updatable_by?(users(:general_chair))
    assert @a_broadcast_email.updatable_by?(users(:a_portfolio_chair))
    assert !@a_broadcast_email.updatable_by?(users(:another_conference_chair))
    assert !@a_broadcast_email.updatable_by?(users(:a_portfolio_member))
    @a_broadcast_email.cfp_id = @a_broadcast_email.cfp_id + 1
    assert !@a_broadcast_email.updatable_by?(users(:administrator))
    assert !@a_broadcast_email.updatable_by?(users(:general_chair))
    assert !@a_broadcast_email.updatable_by?(users(:a_portfolio_chair))
    assert !@a_broadcast_email.updatable_by?(users(:another_conference_chair))
    assert !@a_broadcast_email.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_broadcast_email.destroyable_by?(users(:administrator))
    assert @a_broadcast_email.destroyable_by?(users(:general_chair))
    assert @a_broadcast_email.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_broadcast_email.destroyable_by?(users(:a_portfolio_member))
    assert !@a_broadcast_email.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
