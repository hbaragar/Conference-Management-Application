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
    assert_equal 5, @a_conference.portfolios.count
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

  test "populate menu area for colocated conferences" do
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert menu_item = JoomlaMenu.find_by_name_and_sublevel('Colocated Conferences',0)
    assert category = @a_conference.joomla_general_section.categories.find_by_title('Colocated Conferences')
    assert_match /#{category.id}$/, menu_item.link
    assert_equal 1, category.articles.count
    assert_equal @a_conference, @another_conference.colocated_with
    @another_conference.reload
    article = @another_conference.joomla_article
    assert_equal category.articles.first, article
    assert_match /<h2.*Onward! 2010.*<.h2>/, article.introtext
    assert_match /<a.*href="http:..www.onward-conference.org.".*Onward! 2010.*<.a>/, article.introtext
    assert_match /<img.*src="http:..www.onward-conference.org.logo.gif.*>/, article.introtext
    assert_match /Was part of OOPSLA/, article.introtext
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert_equal 1, category.articles.count
    @another_conference.destroy
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert_equal 0, category.articles.count
  end

  test "populate menu area for supporters" do
    @a_conference.populate_joomla_menu_area_for "Supporters"
    @a_conference.reload
    # Content
    a_call_for_supporter = calls(:a_call_for_supporter)
    assert joomla_article = a_call_for_supporter.joomla_article
    assert_equal a_call_for_supporter, joomla_article.call_for_supporter
    assert_equal a_call_for_supporter.name, joomla_article.title
    assert_equal "Supporters", joomla_article.category.title
    assert_match /#{a_call_for_supporter.portfolio.description}/, joomla_article.introtext
    assert_match /#{a_call_for_supporter.portfolio.public_email_address}/, joomla_article.fulltext
    assert_match /Gold/, joomla_article.fulltext
    assert_match /#{a_call_for_supporter.details}/, joomla_article.fulltext
    # Menu
    assert supporter_menu = JoomlaMenu.find_by_name('Supporters')
    assert_equal 0, supporter_menu.sublevel
    assert_match /show_vote=0/, supporter_menu.params
    supporters_category = JoomlaCategory.find_by_title 'Supporters'
    assert_equal "index.php?option=com_content&view=category&layout=blog&id=#{supporters_category.id}", supporter_menu.link
    assert call_for_supporter_menu = JoomlaMenu.find_by_name('Corporate Support')
    assert_equal 1, call_for_supporter_menu.sublevel
    assert_match /show_vote=0/, call_for_supporter_menu.params
    assert call_for_supporter_article = a_call_for_supporter.joomla_article
    assert_equal "index.php?option=com_content&view=article&id=#{call_for_supporter_article.id}", call_for_supporter_menu.link
  end

  test "populate menu area for call for papers" do
    @a_conference.populate_joomla_menu_area_for "Call for Papers"
    assert_equal 2, JoomlaSection.count
    assert_equal 3, JoomlaCategory.count
    assert_equal 4, JoomlaArticle.count
    assert_equal 3, JoomlaMenu.count
    cfp_article_tests
    @a_conference.populate_joomla_menu_area_for "Call for Papers"
    @a_conference.reload
    assert_equal 2, JoomlaSection.count
    assert_equal 3, JoomlaCategory.count
    assert_equal 4, JoomlaArticle.count
    assert_equal 3, JoomlaMenu.count
    assert cfp_section = JoomlaSection.find_by_alias("cfp")
    assert_equal "Call for Papers", cfp_section.title
    assert_equal 4, cfp_section.count
    assert_equal cfp_section, JoomlaSection.find_by_title("Call for Papers")
    assert_equal 3, cfp_section.categories.count
    categories = cfp_section.categories
    assert_equal (1..3).to_a, categories.collect{|c| c.ordering}
    category_titles = ["Due March 13, 2010", "Due June 13, 2010", "Overview"]
    assert_equal category_titles, categories.collect{|c| c.title}
    cfp_menu = JoomlaMenu.find_by_name "Call for Papers"
    assert_equal 0, cfp_menu.sublevel
    assert_match /show_vote=0/, cfp_menu.params
    assert overview_article = cfp_section.articles.find_by_title("Call for Papers")
    assert_equal "index.php?option=com_content&view=article&id=#{overview_article.id}", cfp_menu.link
    menu_items = cfp_menu.items
    item = menu_items[0]
    assert_equal 1, item.sublevel
    assert_equal "index.php?option=com_content&view=category&layout=blog&id=#{categories[0].id}", item.link
    assert_equal 2, menu_items.count
    assert_equal (1..2).to_a, menu_items.collect{|m| m.ordering}
  end

  def cfp_article_tests
    a_cfp = calls(:a_cfp)
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

  test "populate joomla program menu area" do
    @a_conference.populate_joomla_menu_area_for "Program"
    assert_equal 2, JoomlaSection.count
    assert_equal 4, JoomlaCategory.count
    assert_equal 4, JoomlaArticle.count
    assert_equal 4, JoomlaMenu.count
    @a_conference.populate_joomla_menu_area_for "Program"
    @a_conference.reload
    assert_equal 2, JoomlaSection.count
    assert_equal 4, JoomlaCategory.count
    assert_equal 4, JoomlaArticle.count
    assert_equal 4, JoomlaMenu.count
    assert program_section = JoomlaSection.find_by_alias("program")
    assert_equal "Program", program_section.title
    assert_equal 4, program_section.count
    assert_equal program_section, JoomlaSection.find_by_title("Program")
    assert_equal 4, program_section.categories.count
    categories = program_section.categories
    assert_equal (1..4).to_a, categories.collect{|c| c.ordering}
    category_titles = ["DesignFest", "OOPSLA Research Program", "Overview", "Workshops"]
    assert_equal category_titles, categories.collect{|c| c.title}
    @a_conference.sessions.each {|s| program_article_tests s}
    program_menu = JoomlaMenu.find_by_name "Program"
    assert_equal 0, program_menu.sublevel
    assert_match /show_vote=0/, program_menu.params
    overview_article = program_section.articles.find_by_title("Program")
    assert_equal "index.php?option=com_content&view=article&id=#{overview_article.id}", program_menu.link
    menu_items = program_menu.items
    assert_equal 3, menu_items.count
    assert_equal (1..3).to_a, menu_items.collect{|i| i.ordering}
    assert_equal [1] * 3, menu_items.collect{|i| i.sublevel}
    assert_equal ["DesignFest", "OOPSLA Research Program", "Workshops"], menu_items.collect{|i| i.name}
    categories.each do |c|
      next if c.title == "Overview"
      assert submenu = JoomlaMenu.find_by_name_and_parent(c.title,program_menu.id)
      assert_equal "index.php?option=com_content&view=category&layout=blog&id=#{c.id}", submenu.link
      assert_equal submenu, menu_items[submenu.ordering-1]
    end
    assert program_section = JoomlaSection.find_by_title("Program")
    assert overview_article = program_section.articles.find_by_title("Program")
    assert_equal "Program", overview_article.title
    overview_text = overview_article.fulltext
    assert_match /OOPSLA Research Program/, overview_text
    assert_match /A Session Title/, overview_text
    #assert_match /An Important Title/, overview_text
  end

  def program_article_tests session
    article = session.joomla_article
    assert_equal session.name, article.title
    assert_match /show_category=1/, article.attribs
    assert_match /show_section=1/, article.attribs
    content = article.fulltext
    session.presentations.each do |presentation|
      if session.portfolio.multiple_presentations_per_session?
	assert_match /#{presentation.title}/, content 
      end
      assert_match /#{presentation.abstract}/, content
      presentation.participants.each do |participant|
	assert_match /#{participant.name}/, content
	assert_match /#{participant.affiliation}/, content
	assert_match /#{participant.country}/, content
      end
    end
  end

  test "populate all joomla menu areas" do
    @a_conference.populate_joomla_menu_area_for "All Areas"
    assert_equal 3, JoomlaSection.count
    assert_equal 10, JoomlaCategory.count
    assert_equal 11, JoomlaArticle.count
    assert_equal (1..5).to_a, JoomlaMenu.find_all_by_sublevel(0).collect{|m| m.ordering}
    top_menu = ["Home", "Program", "Call for Papers", "Colocated Conferences", "Supporters"]
    assert_equal top_menu, JoomlaMenu.find_all_by_sublevel(0).collect{|m| m.name}
  end

  def test_create_permissions
  end

  def test_update_permissions
    assert @a_conference.updatable_by?(users(:administrator))
    assert @a_conference.updatable_by?(users(:general_chair))
    assert !@a_conference.updatable_by?(users(:another_conference_chair))
    assert @another_conference.updatable_by?(users(:another_conference_chair))
    assert @another_conference.updatable_by?(users(:general_chair))
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
