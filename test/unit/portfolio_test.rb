require File.dirname(__FILE__) + '/../test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def test_members
    portfolio = portfolios(:splash_general)
    assert_equal 1, portfolio.members.count
  end

end
