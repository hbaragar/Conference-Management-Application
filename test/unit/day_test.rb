require File.dirname(__FILE__) + '/../test_helper'

class DayTest < ActiveSupport::TestCase

  def setup
    @a_conference = conferences(:a_conference)
    @a_conference.populate_joomla_menu_area_for "Program"	# Need to create sessions
    @a_day = @a_conference.days.first
  end

  def test_attributes
    assert_equal 2, @a_conference.days.count
    assert_equal "October 18, 2010 17:30", @a_day.end_of_day.strftime("%B %d, %Y %H:%M")
    assert_equal 15 * 60, @a_day.tick_size
    assert_equal 2*4, @a_day.nticks
    assert_equal 2+2*4, @a_day.ncols	# Include the two columns for room names
    assert_equal 2, @a_day.day_sessions.count
    assert_equal 0, @a_day.evening_sessions.count
    assert_equal 2, @a_day.rooms.count
    assert_equal "October 18, 2010 08:30", @a_day.starts_at.strftime("%B %d, %Y %H:%M")
    assert_equal "October 18, 2010 10:30", @a_day.ends_at.strftime("%B %d, %Y %H:%M")
    assert_equal "A Room", @a_day.rooms[0].name
    assert_nil   @a_day.rooms[1]
  end

  def test_populate_joomla 
    @a_conference.populate_joomla_menu_area_for "Schedule"
    assert_equal 3, JoomlaSection.count
    assert_equal 6, JoomlaCategory.count
    assert_equal 7, JoomlaArticle.count
    assert_equal 7, JoomlaMenu.count
    @a_conference.populate_joomla_menu_area_for "Schedule"
    assert_equal 3, JoomlaSection.count
    assert_equal 6, JoomlaCategory.count
    assert_equal 7, JoomlaArticle.count
    assert_equal 7, JoomlaMenu.count
    assert schedule_section = JoomlaSection.find_by_alias("schedule")
    assert_equal "Schedule", schedule_section.title
    assert_equal 2, schedule_section.categories.count
    categories = schedule_section.categories
    overview_article = schedule_section.articles.find_by_title("Schedule")
    schedule_menu = JoomlaMenu.find_by_name "Schedule"
    assert_equal 0, schedule_menu.sublevel
    assert_match /show_vote=0/, schedule_menu.params
    assert_match /show_section=1/, schedule_menu.params
    assert_equal "index.php?option=com_content&view=article&id=#{overview_article.id}", schedule_menu.link
    menu_items = schedule_menu.items
    assert_equal 2, menu_items.count
  end

end
