require File.dirname(__FILE__) + '/../test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @general = portfolios(:a_conference_general)
    @a_portfolio = portfolios(:a_portfolio)
    @solo_portfolio = portfolios(:single_presentation_portfolio)
    @all_in_one_portfolio = portfolios(:all_in_one_portfolio)
  end

  files_dir = File.dirname(__FILE__) + "/../xml/"

  def test_associations
    assert_equal 1, @general.members.count
    assert_equal 1, @a_portfolio.cfps.count
    assert_equal 4, @a_portfolio.presentations.count
    assert_equal 2, @a_portfolio.participants.count
    assert_equal 1, @a_portfolio.participants_email_list.count
    assert_equal 1, @a_portfolio.days.count
  end

  def test_validate
    @a_portfolio.presentation_fields = "garbage"
    assert !@a_portfolio.valid?
    assert_match /garbage/, @a_portfolio.errors.on(:presentation_fields)
  end

  def test_configured_presentation_fields
    configured_fields = %w(title short_title abstract external_reference).sort
    configurable_fields = (
      configured_fields +
      %w( url reg_number class_type class_format audience objectives resume)
    ).sort
    assert_equal configurable_fields, Presentation.configurable_fields.sort
    assert_equal configured_fields, @a_portfolio.configured_presentation_fields.sort
  end

  test "loading a CyberChair XML file" do
    count = Presentation.count
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v1.xml")
    assert_equal 1+count, Presentation.count
    assert p = Presentation.find_by_external_reference("res0000008")
    assert_equal "Sound and Extensible Renaming for Java", p.title
    assert_equal "SERJ", p.short_title
    assert_match /^Descriptive names/, p.abstract
    assert_equal 3, p.involvements.count
    assert_equal 3, p.participants.count
    author = p.participants.find_by_name("Oege de Moor")
    assert_equal "oege.de.moor@comlab.ox.ac.uk", author.private_email_address
    assert_equal "University of Oxford", author.affiliation
    assert_equal "Britain", author.country
    assert_equal "oege biography", author.bio
    assert author = p.participants.find_by_private_email_address('torbjorn.ekman@comlab.ox.ac.uk')
    assert_equal "TorbjÃ¶rn Ekman", author.name
    assert author = p.participants.find_by_private_email_address('max.schaefer@comlab.ox.ac.uk')
    assert_equal "Max SchÃ¤fer", author.name

  end

  test "reloading CyberChair XML file gets new data" do
    count = Presentation.count
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v1.xml")
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v2.xml")
    assert_equal 1+count, Presentation.count
    assert p = Presentation.find_by_external_reference("res0000008")
    assert_equal "Sound and Extensible Regaming for Java", p.title
    assert_equal 2, p.involvements.count
    assert_equal 2, p.participants.count
    assert !p.participants.find_by_name("Oege de Moor")
    author = p.participants.find_by_private_email_address("torbjorn.ekman@comlab.ox.ac.uk")
    assert_equal "Great Britain", author.country
  end

  test "creating sessions when needed for multiple presentations per session portfolios" do
    count =  @a_portfolio.sessions.count
    presentation = @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v1.xml")
    @a_portfolio.reload
    assert_equal 1+count, @a_portfolio.sessions.count
    session = presentation.session
    assert_match /Unscheduled/, session.name
    session.name = "Another Session"
    session.save
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v2.xml")
    @a_portfolio.reload
    assert_equal 1+count, @a_portfolio.sessions.count
    another_presentation = @a_portfolio.load_presentation_from File.new(files_dir + "poster_1.xml")
    assert_equal 2+count, @a_portfolio.sessions.count
    @a_portfolio.reload
    assert_match /Unscheduled/, another_presentation.session.name
    one_more_presentation = @a_portfolio.load_presentation_from File.new(files_dir + "poster_2.xml")
    @a_portfolio.reload
    assert_equal 2+count, @a_portfolio.sessions.count
  end

  test "creating sessions when needed for single presentation per session portfolios" do
    count =  @solo_portfolio.sessions.count
    solo_presentation = @solo_portfolio.load_presentation_from File.new(files_dir + "poster_1.xml")
    @solo_portfolio.reload
    assert_equal 1+count, @solo_portfolio.sessions.count
    assert_equal solo_presentation.title, solo_presentation.session.name
    another_solo_presentation = @solo_portfolio.load_presentation_from File.new(files_dir + "poster_2.xml")
    @solo_portfolio.reload
    assert_equal 2+count, @solo_portfolio.sessions.count
    assert_equal another_solo_presentation.title, another_solo_presentation.session.name
    # all presentations in one session portfolio
  end

  test "creating sessions when needed for all presentations in one session portfolios" do
    count =  @all_in_one_portfolio.sessions.count
    all_in_one_presentation = @all_in_one_portfolio.load_presentation_from File.new(files_dir + "poster_1.xml")
    @all_in_one_portfolio.reload
    assert_equal 1+count, @all_in_one_portfolio.sessions.count
    assert_equal @all_in_one_portfolio.name, all_in_one_presentation.session.name 
    another_one_presentation = @all_in_one_portfolio.load_presentation_from File.new(files_dir + "poster_2.xml")
    @all_in_one_portfolio.reload
    assert_equal 1+count, @all_in_one_portfolio.sessions.count
    assert_equal @all_in_one_portfolio.name, another_one_presentation.session.name
  end

  test "loading all tutorial data" do
    solo_presentation = @solo_portfolio.load_presentation_from File.new(files_dir + "security.xml")
    assert_equal "Security - Philosophy, Patterns and Practices", solo_presentation.title
    assert_equal "Security", solo_presentation.short_title
    assert_equal "tut0000023", solo_presentation.external_reference
    assert_match /three parts/, solo_presentation.class_format
    assert_equal "Several Areas", solo_presentation.class_type
    assert_equal "Researchers, Practitioners, Managers, Educators", solo_presentation.audience
    assert_match /security related issues/, solo_presentation.abstract
    assert_match /delivers new ideas to software architects, managers, and researchers/, solo_presentation.objectives
  end

  def test_portfolio_lifecycle
    assert @a_portfolio.published?
    @a_portfolio.name = "Name Change"
    assert @a_portfolio.save
    @a_portfolio.reload
    assert @a_portfolio.changes_pending?
  end

  def test_create_permissions
    new_portfolio = Portfolio.new :conference => @a_conference, :name => "New Portfolio"
    assert new_portfolio.creatable_by?(users(:administrator))
    assert new_portfolio.creatable_by?(users(:general_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_member))
    assert !new_portfolio.creatable_by?(users(:a_colocated_conference_chair))
  end

  def test_update_permissions
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert @a_portfolio.updatable_by?(users(:general_chair))
    assert @a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:a_colocated_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
    @general.name = 'Not allowed'
    assert  @general.updatable_by?(users(:administrator))
    assert  @general.updatable_by?(users(:general_chair))
    assert !@general.updatable_by?(users(:a_portfolio_chair))
    assert !@general.updatable_by?(users(:a_colocated_conference_chair))
    assert !@general.updatable_by?(users(:a_portfolio_member))
    @a_portfolio.conference = conferences(:a_colocated_conference)
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert !@a_portfolio.updatable_by?(users(:general_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:a_colocated_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert !@a_portfolio.destroyable_by?(users(:administrator))
    assert !@a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_colocated_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @a_portfolio.members.clear
    assert @a_portfolio.destroyable_by?(users(:administrator))
    assert @a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_colocated_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @general.members.clear
    assert  @general.destroyable_by?(users(:administrator))
    assert !@general.destroyable_by?(users(:general_chair))
    assert !@general.destroyable_by?(users(:a_colocated_conference_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
