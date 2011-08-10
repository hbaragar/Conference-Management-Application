require 'test_helper'

class JoomlaArticleTest < ActiveSupport::TestCase

  def test_validation
    assert cfp = JoomlaArticle.create(:title => "Call for Papers", :alias => "cfp")
    assert_equal "Call for Papers", cfp.title
    assert_equal "cfp", cfp.alias
    assert_equal 1, cfp.ordering
    assert_equal 1, cfp.state
    assert grants = JoomlaArticle.create(:title => "Grants")
    assert_equal "Grants", grants.title
    assert_equal "grants", grants.alias
    assert_equal 2, grants.ordering
    assert !JoomlaArticle.new.valid?
    assert !JoomlaArticle.new(:title => "Call for Prayers", :alias => "cfp").valid?
  end

end
