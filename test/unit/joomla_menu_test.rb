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
    assert_equal 1, cfp.ordering
    assert_equal "mainmenu", cfp.menutype
    assert_equal "component", cfp.type
    assert sag = JoomlaMenu.create(:name => "Scholarships and Grants", :link => "link")
    assert_equal "Scholarships and Grants", sag.name
    assert_equal "scholarships-and-grants", sag.alias
    assert_equal 2, sag.ordering
    assert !JoomlaMenu.new.valid?
    assert !JoomlaMenu.new(:name => "Call for Papers").valid?
    assert !JoomlaMenu.new(:name => "Call for Prayers", :alias => "cfp").valid?
  end

end
