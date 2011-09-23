require 'test_helper'

class DeferredDeletionTest < ActiveSupport::TestCase

  def test_deferred_deletetion_related_to_session_deletion
    a_session = sessions(:a_session)
    a_session.conference.populate_joomla_menu_area_for "Program"
    a_session.reload
    assert the_joomla_article = a_session.joomla_article
    a_session.presentations.*.destroy
    a_session.destroy
    assert_equal 1, DeferredDeletion.count
    assert ! Session.exists?(:id => a_session.id)
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    simulate_load_from_joomla the_joomla_article
    assert   JoomlaArticle.exists?(the_joomla_article.id)
    a_session.conference.populate_joomla_menu_area_for "Program"
    assert ! JoomlaArticle.exists?(the_joomla_article.id)
    assert_equal 0, DeferredDeletion.count
  end

  def simulate_load_from_joomla deleted_object
    clone = JoomlaArticle.create(deleted_object.attributes)	
    clone.connection.execute "update jos_content set id = #{deleted_object.id} where id = #{clone.id}"
  end

end
