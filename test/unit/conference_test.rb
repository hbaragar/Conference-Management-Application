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

  test "generate_general_info" do
    @a_conference.generate_general_information
    @a_conference.reload
    assert @a_conference.joomla_general_section
    assert category = @a_conference.joomla_general_section.categories.find_by_title('Colocated Conferences')
    assert_equal 1, category.articles.count
    assert_equal @a_conference, @another_conference.colocated_with
    @another_conference.reload
    article = @another_conference.joomla_article
    assert_equal category.articles.first, article
    assert_match /Onward! 2010/, article.introtext
    assert_match /Was part of OOPSLA/, article.introtext
    @a_conference.generate_general_information
    assert_equal 1, category.articles.count
    @another_conference.destroy
    @a_conference.reload
    @a_conference.generate_general_information
    assert_equal 0, category.articles.count
  end

  test "generate_cfps" do
    @a_conference.generate_cfps
    cfp_article_tests
    assert_equal 1, JoomlaSection.count
    assert_equal 2, JoomlaCategory.count
    assert_equal 3, JoomlaArticle.count
    assert_equal 3, JoomlaMenu.count
    @a_conference.generate_cfps
    @a_conference.reload
    assert_equal 1, JoomlaSection.count
    assert_equal 2, JoomlaCategory.count
    assert_equal 3, JoomlaArticle.count
    assert_equal 3, JoomlaMenu.count
    cfp_section = JoomlaSection.find(:all).first
    assert_equal "Call for Papers", cfp_section.title
    assert_equal "cfp", cfp_section.alias
    assert_equal 3, cfp_section.count
    assert_equal cfp_section, @a_conference.joomla_cfp_section
    assert_equal 2, cfp_section.categories.count
    categories = cfp_section.categories
    assert_equal 1, categories[0].ordering
    assert_equal 2, categories[1].ordering
    assert_equal "Due March 13, 2010", categories[0].title
    assert_equal "Due June 13, 2010", categories[1].title
    cfp_menu = @a_conference.joomla_cfp_menu
    assert_equal 0, cfp_menu.sublevel
    assert_match /show_vote=0/, cfp_menu.params
    assert_equal "index.php?option=com_content&view=section&layout=blog&id=#{cfp_section.id}", cfp_menu.link
    menu_items = cfp_menu.items
    item = menu_items[0]
    assert_equal 1, item.sublevel
    assert_equal "index.php?option=com_content&view=category&layout=blog&id=#{categories[0].id}", item.link
    assert_equal 2, menu_items.count
    assert_equal 1, menu_items[0].ordering
    assert_equal 2, menu_items[1].ordering
  end

  def cfp_article_tests
    a_cfp = cfps(:a_cfp)
    assert joomla_article = a_cfp.joomla_article
    assert_equal a_cfp, joomla_article.cfp
    assert_equal a_cfp.name, joomla_article.title
    assert_equal "Due March 13, 2010", joomla_article.category.title
    assert_match /#{a_cfp.portfolio.description}/, joomla_article.introtext
    assert_match /#{a_cfp.conference.description}/, joomla_article.fulltext
    assert_match /#{a_cfp.portfolio.public_email_address}/, joomla_article.fulltext
    assert_match /#{a_cfp.portfolio.chairs.first.name}/, joomla_article.fulltext
    assert_match /#{a_cfp.details}/, joomla_article.fulltext
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
