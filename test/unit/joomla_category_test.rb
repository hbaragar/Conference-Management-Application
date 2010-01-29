require 'test_helper'

class JoomlaCategoryTest < ActiveSupport::TestCase

  def test_validation
    assert due_march = JoomlaCategory.create(:title => "Due March 25, 2010", :alias => "due-march")
    assert_equal "Due March 25, 2010", due_march.title
    assert_equal "due-march", due_march.alias
    assert_equal 1, due_march.ordering
    assert due_june = JoomlaCategory.create(:title => "Due June 24, 2010")
    assert_equal "Due June 24, 2010", due_june.title
    assert_equal "due-june-24-2010", due_june.alias
    assert_equal 2, due_june.ordering
    assert !JoomlaCategory.new.valid?
    assert !JoomlaCategory.new(:title => "Due March 25, 2010").valid?
    assert !JoomlaCategory.new(:title => "Due March 31, 2010 for Prayers", :alias => "due-march").valid?
  end

end
