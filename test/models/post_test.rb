require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'published excludes posts scheduled in the future' do
    post = posts(:one)
    post.update!(scheduled_for: 1.hour.from_now)

    assert_not_includes Post.published, post
  end

  test 'published includes posts scheduled for now or earlier' do
    post = posts(:one)
    post.update!(scheduled_for: Time.zone.now)

    assert_includes Post.published, post
  end
end
