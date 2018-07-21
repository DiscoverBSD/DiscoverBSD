require 'test_helper'

class NextPostsServiceTest < ActiveSupport::TestCase
  test "it works ok with `number_of_days` as bigger value" do
    service = NextPostsService.new(minimum_of_posts: 1, end_date: Time.zone.now, number_of_days: 10)
    assert_equal 3, service.perform.size
  end

  test "it works ok with `minimum_of_posts` as bigger value" do
    service = NextPostsService.new(minimum_of_posts: 2, end_date: Time.zone.now, number_of_days: 1)
    assert_equal 3, service.perform.size
  end

  test "posts are from the newest" do
    service = NextPostsService.new(minimum_of_posts: 2, end_date: Time.zone.now, number_of_days: 1)
    result = service.perform
    assert result.first.created_at > result.last.created_at
  end
end
