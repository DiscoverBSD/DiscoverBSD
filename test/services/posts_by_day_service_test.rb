require 'test_helper'

class PostsByDayServiceTest < ActiveSupport::TestCase
  test "it gives correct value for no posts #1" do
    service = PostsByDayService.new(nil)
    assert_nil service.next_date_to_load
    assert_equal [], service.group_by_day
  end

  test "it gives correct value for no posts #2" do
    service = PostsByDayService.new([])
    assert_nil service.next_date_to_load
    assert_equal [], service.group_by_day
  end

  test "it gives correct value for some posts" do
    service = PostsByDayService.new([posts(:one), posts(:two)])
    assert_equal (Time.zone.now - 3.days).strftime('%F'), service.next_date_to_load
    assert_equal [Time.zone.now.strftime('%F'),(Time.zone.now - 2.days).strftime('%F')], service.group_by_day.keys
    assert_equal [posts(:one)], service.group_by_day[Time.zone.now.strftime('%F')]
    assert_equal [posts(:two)], service.group_by_day[(Time.zone.now - 2.days).strftime('%F')]
  end
end
