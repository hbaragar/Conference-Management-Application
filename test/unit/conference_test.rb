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

  def test_portfolios
    splash = conferences(:splash)
    assert_equal 2, splash.portfolios.count
    onward = conferences(:onward)
    assert_equal 1, onward.portfolios.count
    assert_equal "General", onward.portfolios.first.name
  end

end
