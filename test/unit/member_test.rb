require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase


  def setup
    @member = members(:oopsla_member)
    @oopsla_chair = members(:oopsla_chair)
    @splash = conferences(:splash)
    @oopsla = portfolios(:splash_oopsla)
  end

  def test_create_permissions
    new_member = Member.new :portfolio => @oopsla, :name => "A new member"
    assert new_member.creatable_by?(users(:administrator))
    assert new_member.creatable_by?(users(:splash_chair))
    assert new_member.creatable_by?(users(:oopsla_chair))
    assert !new_member.creatable_by?(users(:oopsla_member))
    assert !new_member.creatable_by?(users(:onward_chair))
  end

  def test_update_permissions
    assert @member.updatable_by?(users(:administrator))
    assert @member.updatable_by?(users(:splash_chair))
    assert @member.updatable_by?(users(:oopsla_chair))
    assert !@member.updatable_by?(users(:oopsla_member))
    assert !@member.updatable_by?(users(:onward_chair))
    assert @oopsla_chair.updatable_by?(users(:administrator))
    assert @oopsla_chair.updatable_by?(users(:splash_chair))
    assert @oopsla_chair.updatable_by?(users(:oopsla_chair))
    assert !@oopsla_chair.updatable_by?(users(:oopsla_member))
    assert !@oopsla_chair.updatable_by?(users(:onward_chair))
    @oopsla_chair.chair = false
    assert @oopsla_chair.updatable_by?(users(:administrator))
    assert @oopsla_chair.updatable_by?(users(:splash_chair))
    assert !@oopsla_chair.updatable_by?(users(:oopsla_chair))
    assert !@oopsla_chair.updatable_by?(users(:oopsla_member))
    assert !@oopsla_chair.updatable_by?(users(:onward_chair))
  end

  def test_destroy_permissions
    assert @member.destroyable_by?(users(:administrator))
    assert @member.destroyable_by?(users(:splash_chair))
    assert @member.destroyable_by?(users(:oopsla_chair))
    assert !@member.destroyable_by?(users(:oopsla_member))
    assert !@member.destroyable_by?(users(:onward_chair))
    assert @oopsla_chair.destroyable_by?(users(:administrator))
    assert @oopsla_chair.destroyable_by?(users(:splash_chair))
    assert !@oopsla_chair.destroyable_by?(users(:oopsla_chair))
    assert !@oopsla_chair.destroyable_by?(users(:oopsla_member))
    assert !@oopsla_chair.destroyable_by?(users(:onward_chair))
  end

  def test_view_permissions
  end

end
