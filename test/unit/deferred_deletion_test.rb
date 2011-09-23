require 'test_helper'

class DeferredDeletionTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
  end

  def test_deferred_deletetion_related_to_call_deletion
    a_call = @a_conference.portfolios.*.cfps.flatten.first
    @a_conference.populate_joomla_menu_area_for "Program"
    a_call.reload
    assert the_joomla_article = a_call.joomla_article
    a_call.destroy
    assert_equal 1, DeferredDeletion.count
    assert ! Call.exists?(:id => a_call.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    simulate_load_from_joomla the_joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert_equal 0, DeferredDeletion.count
  end

  def test_deferred_deletetion_related_to_portfolio_deletion
    a_portfolio = portfolios(:a_portfolio)
    @a_conference.populate_joomla_menu_area_for "Program"
    a_portfolio.reload
    assert the_joomla_article = a_portfolio.joomla_article
    assert the_joomla_category = a_portfolio.joomla_category
    assert the_joomla_menu = a_portfolio.joomla_menu
    a_portfolio.destroy
    assert_equal 6, DeferredDeletion.count
    assert ! Portfolio.exists?(:id => a_portfolio.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert ! JoomlaCategory.exists?(the_joomla_category.id)
    assert ! JoomlaMenu.exists?(the_joomla_menu.id)
    simulate_load_from_joomla the_joomla_article
    simulate_load_from_joomla the_joomla_category
    simulate_load_from_joomla the_joomla_menu
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    assert   JoomlaCategory.exists?(the_joomla_category.id)
    assert   JoomlaMenu.exists?(the_joomla_menu.id)
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert ! JoomlaCategory.exists?(the_joomla_category.id)
    assert ! JoomlaMenu.exists?(the_joomla_menu.id)
    assert_equal 0, DeferredDeletion.count
  end

  def test_deferred_deletetion_related_to_session_deletion
    a_session = @a_conference.sessions.first
    @a_conference.populate_joomla_menu_area_for "Program"
    a_session.reload
    assert the_joomla_article = a_session.joomla_article
    a_session.presentations.*.destroy
    a_session.destroy
    assert_equal 1, DeferredDeletion.count
    assert ! Session.exists?(:id => a_session.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    simulate_load_from_joomla the_joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert_equal 0, DeferredDeletion.count
  end

  def test_deferred_deletetion_related_to_conference_deletion
    new_colo = @a_conference.colocated_conferences.create(:name => "New Colocated Conference")
    @a_conference.populate_joomla_menu_area_for "Colocated Conferences"
    new_colo.reload
    assert   the_joomla_article = new_colo.joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    new_colo.destroy
    assert_equal 1, DeferredDeletion.count
    assert ! Conference.exists?(:id => new_colo.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    simulate_load_from_joomla the_joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert_equal 0, DeferredDeletion.count
  end

  def test_deferred_deletetion_related_to_facility_area_deletion
    a_facility_area = @a_conference.facility_areas.create(:name => "New Facility Area")
    @a_conference.populate_joomla_menu_area_for "Program"
    a_facility_area.reload
    assert the_joomla_article = a_facility_area.joomla_article
    a_facility_area.destroy
    assert_equal 1, DeferredDeletion.count
    assert ! FacilityArea.exists?(:id => a_facility_area.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    simulate_load_from_joomla the_joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    @a_conference.reload
    @a_conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert_equal 0, DeferredDeletion.count
  end

  def simulate_load_from_joomla deleted_object
    klass = deleted_object.class
    clone = klass.create(deleted_object.attributes)	
    clone.connection.execute "update #{klass.table_name} set id = #{deleted_object.id} where id = #{clone.id}"
  end

end
