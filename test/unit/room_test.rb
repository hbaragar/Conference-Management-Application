require File.dirname(__FILE__) + '/../test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_room = rooms(:a_room)
  end

  def test_portfolio_lifecycle
    a_portfolio = @a_room.portfolios.first
    a_portfolio.state = "published"
    assert a_portfolio.save
    @a_room.name = "Name Change"
    assert @a_room.save
    assert a_portfolio.reload.changes_pending?
  end

end
