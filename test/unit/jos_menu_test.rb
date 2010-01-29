require 'test_helper'

class JosMenuTest < ActiveSupport::TestCase


  test "validation" do
    assert cfp = JosMenu.create(:name => "Call for Papers", :alias => "cfp")
    assert_equal "Call for Papers", cfp.name
    assert_equal "cfp", cfp.alias
    assert_equal 1, cfp.ordering
    assert sag = JosMenu.create(:name => "Scholarships and Grants")
    assert_equal "Scholarships and Grants", sag.name
    assert_equal "scholarships-and-grants", sag.alias
    assert_equal 2, sag.ordering
    assert !JosMenu.new.valid?
    assert !JosMenu.new(:name => "Call for Papers").valid?
    assert !JosMenu.new(:name => "Call for Prayers", :alias => "cfp").valid?
  end

end
