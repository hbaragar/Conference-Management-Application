require File.dirname(__FILE__) + '/../test_helper'

class SessionTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_session = sessions(:a_session)
    @a_portfolio = @a_session.portfolio
  end

  def test_associations
    assert_equal 3, @a_session.presentations.count
    assert_equal 2, @a_session.involvements.count
  end

  def test_updates_to_presentation_if_session_is_single_presentation
    single = sessions(:c_session)
    single.name = "Presentation to be Renamed"
    single.save
    assert_equal single.name, single.presentations.first.title
    single.short_name = "P.t.b.R"
    single.save
    assert_equal single.short_name, single.presentations.first.short_title
  end

  def test_before_create
    @a_portfolio.typical_session_duration = 510
    @a_portfolio.save
    @a_portfolio.reload
    session = @a_portfolio.sessions.create!(:name => "A New session")
    assert_equal @a_portfolio, session.portfolio
    assert_equal 510, session.duration
  end

  def test_to_html
    html = @a_session.to_html
    assert_match /Mon 8:30-10:00 am.*Room TBD/, html
    assert_match /An Important Title/, html
    assert_match /An Abstract/, html
    assert_match /Paper Author/, html
    assert_match /Author Affiliation/, html
    assert_match /Another Important Title/, html
    assert_match /Another Abstract/, html
    assert_match /A Really Important Title/, html
    assert_match /More Abstract Abstract/, html
    assert_no_match /Another Session/, html
    assert_no_match /An Interesting Title/, html
    assert_no_match /An Interesting Abstract/, html
  end

  def test_presentation_order
    html = @a_session.to_html
    assert_match /An Important Title.*Another Important Title.*A Really Important Title/m, html
    @a_session.presentations.each {|p| p.move_to_top}
    @a_session.reload
    html = @a_session.to_html
    assert_match /A Really Important Title.*Another Important Title.*An Important Title/m, html
  end

  def test_overlaps
    assert   sessions(:a_session).overlaps?(sessions(:b_session))
    assert   sessions(:b_session).overlaps?(sessions(:a_session))
    assert ! sessions(:a_session).overlaps?(sessions(:c_session))
    assert ! sessions(:c_session).overlaps?(sessions(:a_session))
    assert ! sessions(:b_session).overlaps?(sessions(:c_session))
    assert ! sessions(:c_session).overlaps?(sessions(:b_session))
  end

  def test_portfolio_lifecycle
    @a_session.name = "Name Change"
    assert @a_session.save
    assert @a_session.portfolio.changes_pending?
  end

  def test_create_permissions
    new_session = @a_portfolio.sessions.new 
    assert  new_session.creatable_by?(users(:administrator))
    assert  new_session.creatable_by?(users(:general_chair))
    assert  new_session.creatable_by?(users(:a_portfolio_chair))
    assert !new_session.creatable_by?(users(:a_portfolio_member))
    assert !new_session.creatable_by?(users(:a_colocated_conference_chair))
  end

  def test_update_permissions
    assert  @a_session.updatable_by?(users(:administrator))
    assert  @a_session.updatable_by?(users(:general_chair))
    assert  @a_session.updatable_by?(users(:a_portfolio_chair))
    assert !@a_session.updatable_by?(users(:a_colocated_conference_chair))
    assert !@a_session.updatable_by?(users(:a_portfolio_member))
  end

  def test_destroy_permissions
    @a_session.presentations.*.destroy
    assert  @a_session.destroyable_by?(users(:administrator))
    assert  @a_session.destroyable_by?(users(:general_chair))
    assert  @a_session.destroyable_by?(users(:a_portfolio_chair))
    assert !@a_session.destroyable_by?(users(:a_portfolio_member))
    assert !@a_session.destroyable_by?(users(:a_colocated_conference_chair))
  end

  def test_view_permissions
  end

end
