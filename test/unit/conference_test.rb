require File.dirname(__FILE__) + '/../test_helper'

class ConferenceTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @another_conference = conferences(:another_conference)
  end

  def test_fields
    assert_equal "Splash 2010", @a_conference.name
    assert_equal "Onward! 2010", @another_conference.name
    assert_equal "Splash 2010", @another_conference.colocated_with.name
    assert_equal 1, @a_conference.colocated_conferences.size
    assert_equal "Onward! 2010", @a_conference.colocated_conferences.first.name
  end

  def test_portfolios
    assert_equal 4, @a_conference.portfolios.count
    assert_equal 1, @another_conference.portfolios.count
    assert_equal "General", @another_conference.portfolios.first.name
  end

  def test_chair
    assert @a_conference.chair?(users(:general_chair))
    assert !@a_conference.chair?(users(:a_portfolio_chair))
    assert !@a_conference.chair?(users(:a_portfolio_member))
    assert !@a_conference.chair?(users(:another_conference_chair))
  end

  def test_after_create
    count = Portfolio.count
    new_one = Conference.create(:name => 'A new conference')
    assert_equal 1, new_one.portfolios.count
    assert_equal 1+count, Portfolio.count
    assert_equal "General", new_one.portfolios.first.name
  end

  test "publish_cfp" do
    @a_conference.publish_cfp
    assert_equal 1, JosSection.count
    #assert_equal 2, JosCategory.count
    assert_equal 3, JosArticle.count
    @a_conference.publish_cfp
    assert_equal 1, JosSection.count
    #assert_equal 2, JosCategory.count
    assert_equal 3, JosArticle.count
    cfp_section = JosSection.find(:all).first
    assert_equal "Call for Papers", cfp_section.title
    assert_equal "cfp", cfp_section.alias
    assert_equal 3, cfp_section.count
    @a_conference.reload
    assert_equal cfp_section, @a_conference.joomla_cfp_section
  end

  def test_create_permissions
  end

  def test_update_permissions
    assert @a_conference.updatable_by?(users(:administrator))
    assert @a_conference.updatable_by?(users(:general_chair))
    assert !@a_conference.updatable_by?(users(:another_conference_chair))
    assert @another_conference.updatable_by?(users(:another_conference_chair))
    assert !@another_conference.updatable_by?(users(:general_chair))
    assert !@a_conference.updatable_by?(users(:a_portfolio_chair))
    assert !@a_conference.updatable_by?(users(:a_portfolio_member))
    @a_conference.colocated_with_id = 5
    assert @a_conference.updatable_by?(users(:administrator))
    assert !@a_conference.updatable_by?(users(:general_chair))
  end

  def test_destroy_permissions
    assert !@a_conference.destroyable_by?(users(:administrator))
    assert !@a_conference.destroyable_by?(users(:general_chair))
    assert !@a_conference.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_conference.destroyable_by?(users(:a_portfolio_member))
    @a_conference.portfolios.clear
    assert @a_conference.destroyable_by?(users(:administrator))
  end

  def test_view_permissions
  end

end
