require 'test_helper'

class JosArticleTest < ActiveSupport::TestCase

  def test_validation
    assert cfp = JosArticle.create(:title => "Call for Papers", :alias => "cfp")
    assert_equal "Call for Papers", cfp.title
    assert_equal "cfp", cfp.alias
    assert_equal 1, cfp.ordering
    assert_equal 1, cfp.state
    assert sag = JosArticle.create(:title => "Scholarships and Grants")
    assert_equal "Scholarships and Grants", sag.title
    assert_equal "scholarships-and-grants", sag.alias
    assert_equal 2, sag.ordering
    assert !JosArticle.new.valid?
    assert !JosArticle.new(:title => "Call for Papers").valid?
    assert !JosArticle.new(:title => "Call for Prayers", :alias => "cfp").valid?
  end

end
