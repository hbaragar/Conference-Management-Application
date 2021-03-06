require 'test_helper'

class JoomlaSectionTest < ActiveSupport::TestCase

  test "validation" do
    assert cfp = JoomlaSection.create(:title => "Call for Papers", :alias => "cfp")
    assert_equal "Call for Papers", cfp.title
    assert_equal "cfp", cfp.alias
    assert_equal 1, cfp.ordering
    assert_equal "content", cfp.scope
    assert grants = JoomlaSection.create(:title => "Grants")
    assert_equal "Grants", grants.title
    assert_equal "grants", grants.alias
    assert_equal 2, grants.ordering
    assert_equal "content", grants.scope
    assert !JoomlaSection.new.valid?
    assert !JoomlaSection.new(:title => "Call for Papers").valid?
    assert !JoomlaSection.new(:title => "Call for Prayers", :alias => "cfp").valid?
  end

end
