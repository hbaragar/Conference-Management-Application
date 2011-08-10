require 'test_helper'

class JoomlaMenuTest < ActiveSupport::TestCase


  test "validation" do
    assert cfp = JoomlaMenu.create(
      :name => "Call for Papers",
      :alias => "cfp",
      :link => "link"
    )
    assert_equal "Call for Papers", cfp.name
    assert_equal "cfp", cfp.alias
    assert_equal "link", cfp.link
    assert_equal 20, cfp.componentid
    assert_equal 1, cfp.ordering
    assert_equal "mainmenu", cfp.menutype
    assert_equal "component", cfp.type
    assert grants = JoomlaMenu.create(:name => "Grants", :link => "link")
    assert_equal "Grants", grants.name
    assert_equal "grants", grants.alias
    assert_equal 2, grants.ordering
    assert !JoomlaMenu.new.valid?
    assert !JoomlaMenu.new(:name => "Call for Papers").valid?
    assert !JoomlaMenu.new(:name => "Call for Prayers", :alias => "cfp").valid?
  end

end
