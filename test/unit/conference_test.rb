require File.dirname(__FILE__) + '/../test_helper'

class ConferenceTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_colocated_conference = conferences(:a_colocated_conference)
    @a_participant = participants(:a_participant)
  end

  def test_fields
    assert_equal "Splash 2010", @a_conference.name
    assert_equal "Onward! 2010", @a_colocated_conference.name
    assert_equal "Splash 2010", @a_colocated_conference.hosting_conference.name
    assert_equal 1, @a_conference.colocated_conferences.size
    assert_equal "Onward! 2010", @a_conference.colocated_conferences.first.name
  end

  def test_associations
    assert_equal 5, @a_conference.portfolios.count
    assert_equal 1, @a_colocated_conference.portfolios.count
    assert_equal "General", @a_colocated_conference.portfolios.first.name
    assert_equal 3, @a_conference.participants.count
    @a_conference.participants.*.set_conflicted!
    assert_equal 1, @a_conference.participants.conflicted.count
    assert_equal @a_participant, @a_conference.participants.conflicted.first
    conflict = "A Session Title @ Mon 8:30-10:00 am vs Another Session Title @ Mon 9:00-10:30 am"
    assert_equal [conflict], @a_participant.conflicting_sessions
    assert_equal [], participants(:b_participant).conflicting_sessions
    assert_equal 2, @a_conference.facilities.count
    assert_equal 2, @a_conference.rooms.count
    assert_equal 2, @a_colocated_conference.facilities.count
    assert_equal 1, @a_conference.roomless_sessions.count
  end

  def test_chair
    assert  @a_conference.chair?(users(:general_chair))
    assert  @a_colocated_conference.chair?(users(:general_chair))
    assert !@a_conference.chair?(users(:a_portfolio_chair))
    assert !@a_conference.chair?(users(:a_portfolio_member))
    assert !@a_conference.chair?(users(:a_colocated_conference_chair))
  end

  def test_after_create
    count = Portfolio.count
    new_one = Conference.create!(:name => 'A new conference')
    assert_equal 1, new_one.portfolios.count
    assert_equal 1+count, Portfolio.count
    assert_equal "General", new_one.portfolios.first.name
  end

  test "populate menu area for attending" do
    @a_conference.populate_joomla_menu_area_for "Attending"
    assert menu = JoomlaMenu.find_by_name_and_sublevel('Attending',0)
    #
    assert section = JoomlaSection.find_by_title('Attending')
    assert category = section.categories.find_by_title('Registering')
    assert article = category.articles.find_by_title('Registering')
    assert_equal section.id, article.sectionid
    assert_match /#{article.id}$/, menu.items.find_by_name('Registering').link
    assert_equal 1, category.articles.count
    #
    assert category = section.categories.find_by_title('Getting to SPLASH')
    assert_match /#{category.id}$/, menu.items.find_by_name('Getting to SPLASH').link
    assert_equal 3, category.articles.count
    #
    assert category = section.categories.find_by_title('While at SPLASH')
    assert_match /#{category.id}$/, menu.items.find_by_name('While at SPLASH').link
    #
    assert category = section.categories.find_by_title('Conference Facility Floor Plans')
    assert_match /#{category.id}$/, menu.items.find_by_name('Conference Facility Floor Plans').link
    assert_equal 2, category.articles.count
  end

  test "populate menu area for grants" do
    @a_conference.populate_joomla_menu_area_for "Grants"
    assert menu = JoomlaMenu.find_by_name_and_sublevel('Grants',0)
    #
    assert section = JoomlaSection.find_by_title('Grants')
    assert_equal 0, section.articles.count
  end

  test "populate menu area for colocated conferences" do
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert menu_item = JoomlaMenu.find_by_name_and_sublevel('Colocated Conferences',0)
    assert category = @a_conference.joomla_general_section.categories.find_by_title('Colocated Conferences')
    assert_match /#{category.id}$/, menu_item.link
    assert_equal 1, category.articles.count
    assert_equal @a_conference, @a_colocated_conference.hosting_conference
    @a_colocated_conference.reload
    article = @a_colocated_conference.joomla_article
    assert_equal category.articles.first, article
    assert_match /<h2.*Onward! 2010.*<.h2>/, article.introtext
    assert_match /<a.*href="http:..www.onward-conference.org.".*Onward! 2010.*<.a>/, article.introtext
    assert_match /<img.*src="http:..www.onward-conference.org.logo.gif.*>/, article.introtext
    assert_match /Was part of OOPSLA/, article.introtext
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert_equal 1, category.articles.count
    @a_colocated_conference.destroy
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    assert_equal 0, category.articles.count
  end

  test "populate menu area for committee" do
    @a_conference.populate_joomla_menu_area_for "Committee"
    assert menu_item = JoomlaMenu.find_by_name_and_sublevel('Committee',0)
    assert category = JoomlaCategory.find_by_title('Committee')
    assert_equal 4, category.articles.count
    name = "OOPSLA Research Program"
    assert a_portfolio = @a_conference.portfolios.find_by_name(name)
    article = a_portfolio.joomla_article
    assert_match /<th[^>]*>#{name}<.th>/, article.introtext
    assert_match /Martin Rinard.*MIT.*USA/m, article.introtext
    assert_match /Gary Leavens/, article.introtext
    assert overview_article = category.articles.find_by_title('Committee')
    assert_match /Martin Rinard.*MIT.*USA/m, overview_article.fulltext
    assert_no_match /Gary Leavens/, overview_article.fulltext
    assert_match /Onward! 2010/, overview_article.fulltext
    assert_match /www.onward-conference.org/, overview_article.fulltext
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
    cfp_article_tests
    @a_conference.populate_joomla_menu_area_for "Call for Papers"
    @a_conference.reload
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
    assert_equal "index.php?option=com_content&view=category&layout=blog&id=#{categories.first.id}", item.link
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
    assert_match /#{a_cfp.external_reviewers.first}/, joomla_article.fulltext
    assert_match /#{a_cfp.footnotes}/, joomla_article.fulltext
  end

  test "populate joomla program menu area" do
    @a_conference.populate_joomla_menu_area_for "Program"
    @a_conference.populate_joomla_menu_area_for "Program"
    @a_conference.reload
    assert program_section = JoomlaSection.find_by_alias("program")
    assert_equal "Program", program_section.title
    assert_equal 4, program_section.count
    categories = program_section.categories
    assert_equal (1..4).to_a, categories.collect{|c| c.ordering}
    category_titles = ["OOPSLA Research Program", "Workshops", "DesignFest", "Overview"]
    assert_equal category_titles, categories.collect{|c| c.title}
    @a_conference.sessions.each {|s| program_article_tests s}
    program_menu = JoomlaMenu.find_by_name "Program"
    assert_equal 0, program_menu.sublevel
    assert_match /show_vote=0/, program_menu.params
    assert_match /show_section=1/, program_menu.params
    overview_article = program_section.articles.find_by_title("Program")
    assert_equal "index.php?option=com_content&view=article&id=#{overview_article.id}", program_menu.link
    menu_items = program_menu.items
    assert_equal 3, menu_items.count
    assert_equal (1..3).to_a, menu_items.collect{|i| i.ordering}
    assert_equal [1] * 3, menu_items.collect{|i| i.sublevel}
    assert_equal ["OOPSLA Research Program", "Workshops", "DesignFest"], menu_items.collect{|i| i.name}
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
    assert_equal 6, JoomlaSection.count
    assert_equal 16, JoomlaCategory.count
    assert_equal (1..9).to_a, JoomlaMenu.find_all_by_sublevel(0).collect{|m| m.ordering}
    top_menu = [
      "Home",
      "Grants",
      "Attending",
      "Schedule",
      "Program",
      "Call for Papers",
      "Committee",
      "Colocated Conferences",
      "Supporters"
    ]
    assert_equal top_menu, JoomlaMenu.find_all_by_sublevel(0).collect{|m| m.name}
    # Make sure menu items always have their correct ordering
    JoomlaMenu.first.move_to_bottom	# Scramble ordering
    JoomlaMenu.last.move_higher		# ... make sure its scrambled
    @a_conference.populate_joomla_menu_area_for "Program"
    assert_equal top_menu, JoomlaMenu.find_all_by_sublevel(0).collect{|m| m.name}
  end

  def test_create_permissions
  end

  def test_update_permissions
    assert @a_conference.updatable_by?(users(:administrator))
    assert @a_conference.updatable_by?(users(:general_chair))
    assert !@a_conference.updatable_by?(users(:a_colocated_conference_chair))
    assert @a_colocated_conference.updatable_by?(users(:a_colocated_conference_chair))
    assert @a_colocated_conference.updatable_by?(users(:general_chair))
    assert !@a_conference.updatable_by?(users(:a_portfolio_chair))
    assert !@a_conference.updatable_by?(users(:a_portfolio_member))
    @a_conference.hosting_conference_id = 5
    assert @a_conference.updatable_by?(users(:administrator))
    assert !@a_conference.updatable_by?(users(:general_chair))
  end

  def test_destroy_permissions
    assert  @a_conference.destroyable_by?(users(:administrator))
    assert !@a_conference.destroyable_by?(users(:general_chair))
    assert !@a_conference.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_conference.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
