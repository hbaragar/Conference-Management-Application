require File.dirname(__FILE__) + '/../test_helper'

class ConferenceTest < ActiveSupport::TestCase

  def test_fields
    splash = conferences(:splash)
    onward = conferences(:onward)
    assert_equal "Splash 2010", splash.name
    assert_equal "Onward! 2010", onward.name
    assert_equal "Splash 2010", onward.colocated_with.name
    assert_equal 1, splash.colocated_conferences.size
    assert_equal "Onward! 2010", splash.colocated_conferences.first.name
  end

end
