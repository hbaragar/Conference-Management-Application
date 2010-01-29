require File.dirname(__FILE__) + '/../test_helper'

class CfpTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_portfolio = portfolios(:a_portfolio)
    @a_cfp = cfps(:a_cfp)
  end

  def test_publish
    @a_cfp.publish
    @a_cfp.reload
    assert joomla_article = @a_cfp.joomla_article
    joomla_article.reload
    assert_match /#{@a_cfp.portfolio.description}/, joomla_article.introtext
    assert_match /#{@a_cfp.conference.description}/, joomla_article.fulltext
    assert_match /#{@a_cfp.portfolio.public_email_address}/, joomla_article.fulltext
    assert_match /#{@a_cfp.portfolio.chairs.first.name}/, joomla_article.fulltext
    assert_match /#{@a_cfp.details}/, joomla_article.fulltext
    assert_equal "Due March 13, 2010", @a_cfp.joomla_category_title
  end

  def test_create_permissions
    new_cfp = Cfp.new :portfolio => @a_portfolio, :due_on => 1.months.from_now
    assert new_cfp.creatable_by?(users(:administrator))
    assert new_cfp.creatable_by?(users(:general_chair))
    assert new_cfp.creatable_by?(users(:a_portfolio_chair))
    assert !new_cfp.creatable_by?(users(:a_portfolio_member))
    assert !new_cfp.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_cfp.updatable_by?(users(:administrator))
    assert @a_cfp.updatable_by?(users(:general_chair))
    assert @a_cfp.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_member))
    @a_cfp.portfolio = portfolios(:a_conference_general)
    assert @a_cfp.updatable_by?(users(:administrator))
    assert !@a_cfp.updatable_by?(users(:general_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.updatable_by?(users(:another_conference_chair))
    assert !@a_cfp.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert @a_cfp.destroyable_by?(users(:administrator))
    assert @a_cfp.destroyable_by?(users(:general_chair))
    assert @a_cfp.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_cfp.destroyable_by?(users(:a_portfolio_member))
    assert !@a_cfp.destroyable_by?(users(:another_conference_chair))
  end

  def test_view_permissions
  end

end
