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
    assert_equal '2018-07-15', service.next_date_to_load
    assert_equal ["2018-07-18","2018-07-16"], service.group_by_day.keys
    assert_equal [posts(:one)], service.group_by_day["2018-07-18"]
    assert_equal [posts(:two)], service.group_by_day["2018-07-16"]
  end
end
