require 'test_helper'

class JosSectionTest < ActiveSupport::TestCase

  test "validation" do
    assert cfp = JosSection.create(:title => "Call for Papers", :alias => "cfp")
    assert_equal "Call for Papers", cfp.title
    assert_equal "cfp", cfp.alias
    assert_equal 1, cfp.ordering
    assert_equal "content", cfp.scope
    assert sag = JosSection.create(:title => "Scholarships and Grants")
    assert_equal "Scholarships and Grants", sag.title
    assert_equal "scholarships-and-grants", sag.alias
    assert_equal 2, sag.ordering
    assert_equal "content", sag.scope
    assert !JosSection.new.valid?
    assert !JosSection.new(:title => "Call for Papers").valid?
    assert !JosSection.new(:title => "Call for Prayers", :alias => "cfp").valid?
  end

end
