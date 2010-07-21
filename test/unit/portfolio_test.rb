require File.dirname(__FILE__) + '/../test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @general = portfolios(:a_conference_general)
    @a_portfolio = portfolios(:a_portfolio)
  end

  files_dir = File.dirname(__FILE__) + "/../xml/"

  def test_dependents
    assert_equal 1, @general.members.count
    assert_equal 1, @a_portfolio.cfps.count
    assert_equal 1, @a_portfolio.presentations.count
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
    assert_equal "oege biography", author.bio
  end

  test "reloading CyberChair XML file does not clobber existing data" do
    count = Presentation.count
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v1.xml")
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v2.xml")
    assert_equal 1+count, Presentation.count
    assert p = Presentation.find_by_external_reference("res0000008")
    assert_equal "Sound and Extensible Regaming for Java", p.title
    assert_equal 2, p.involvements.count
    assert_equal 2, p.participants.count
  end

  test "creating sessions when needed" do
    count =  @a_portfolio.sessions.count
    presentation = @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v1.xml")
    @a_portfolio.reload
    assert_equal 1+count, @a_portfolio.sessions.count
    session = presentation.session
    assert_match /To Be Scheduled/, session.name
    session.name = "Another Session"
    session.save
    @a_portfolio.load_presentation_from File.new(files_dir + "cyber_chair_v2.xml")
    @a_portfolio.reload
    assert_equal 1+count, @a_portfolio.sessions.count
    another_presentation = @a_portfolio.load_presentation_from File.new(files_dir + "poster_1.xml")
    assert_equal 2+count, @a_portfolio.sessions.count
    @a_portfolio.reload
    assert_match /To Be Scheduled/, another_presentation.session.name
    one_more_presentation = @a_portfolio.load_presentation_from File.new(files_dir + "poster_2.xml")
    assert_equal 2+count, @a_portfolio.sessions.count
    @a_portfolio.reload
    #soa_session = Presentation.load_from(File.new(files_dir + "soa.xml"))[0].session
    #assert_equal "SOA in Practice", soa_session.name
    #assert_match "(6)", soa_session.title
    #assert_equal @tutorials_category, soa_session.jos_category
    #security_session = Presentation.load_from(File.new(files_dir + "security.xml"))[0].session
    #assert_equal "Security - Philosophy, Patterns and Practices", security_session.name
    #poster_session = Presentation.load_from(File.new(files_dir + "poster_1.xml"))[0].session
    #assert_equal "Posters", poster_session.name
    #assert_equal @posters_category, poster_session.jos_category
    #count = Session.count
    #poster_session = Presentation.load_from(File.new(files_dir + "poster_2.xml"))[0].session
    #assert_equal "Posters", poster_session.name
    #assert_equal count, Session.count
  end

  def test_create_permissions
    new_portfolio = Portfolio.new :conference => @a_conference, :name => "New Portfolio"
    assert new_portfolio.creatable_by?(users(:administrator))
    assert new_portfolio.creatable_by?(users(:general_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_chair))
    assert !new_portfolio.creatable_by?(users(:a_portfolio_member))
    assert !new_portfolio.creatable_by?(users(:another_conference_chair))
  end

  def test_update_permissions
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert @a_portfolio.updatable_by?(users(:general_chair))
    assert @a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:another_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
    @general.name = 'Not allowed'
    assert !@general.updatable_by?(users(:administrator))
    assert !@general.updatable_by?(users(:general_chair))
    assert !@general.updatable_by?(users(:a_portfolio_chair))
    assert !@general.updatable_by?(users(:another_conference_chair))
    assert !@general.updatable_by?(users(:a_portfolio_member))
    @a_portfolio.conference = conferences(:another_conference)
    assert @a_portfolio.updatable_by?(users(:administrator))
    assert !@a_portfolio.updatable_by?(users(:general_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.updatable_by?(users(:another_conference_chair))
    assert !@a_portfolio.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    assert !@a_portfolio.destroyable_by?(users(:administrator))
    assert !@a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:another_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @a_portfolio.members.clear
    assert @a_portfolio.destroyable_by?(users(:administrator))
    assert @a_portfolio.destroyable_by?(users(:general_chair))
    assert !@a_portfolio.destroyable_by?(users(:another_conference_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_portfolio.destroyable_by?(users(:a_portfolio_member))
    @general.members.clear
    assert !@general.destroyable_by?(users(:administrator))
    assert !@general.destroyable_by?(users(:general_chair))
    assert !@general.destroyable_by?(users(:another_conference_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_chair))
    assert !@general.destroyable_by?(users(:a_portfolio_member))
  end

  def test_view_permissions
  end

end
