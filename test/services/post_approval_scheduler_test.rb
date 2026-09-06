require 'test_helper'

class PostApprovalSchedulerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @post = posts(:four)
    @admin = users(:one)
    clear_enqueued_jobs
  end

  test 'approves immediately and queues the post now' do
    travel_to Time.zone.parse('2026-08-12 10:00:00') do
      PostApprovalScheduler.new(post: @post, admin: @admin, mode: 'now').perform

      assert_in_delta Time.zone.now.to_f, @post.reload.scheduled_for.to_f, 1
      assert_equal true, @post.approved
      assert_equal @admin, @post.approved_by
      assert_enqueued_with(job: TootPostJob, args: [@post])
    end
  end

  test 'queues immediately when there are no scheduled posts' do
    Post.approved.delete_all

    travel_to Time.zone.parse('2026-08-12 10:00:00') do
      PostApprovalScheduler.new(post: @post, admin: @admin, mode: 'later').perform

      assert_in_delta Time.zone.now.to_f, @post.reload.scheduled_for.to_f, 1
    end
  end

  test 'queues immediately when the latest post was more than one hour ago' do
    travel_to Time.zone.parse('2026-08-12 10:00:00') do
      Post.approved.update_all(approved_at: 2.hours.ago, scheduled_for: nil)
      PostApprovalScheduler.new(post: @post, admin: @admin, mode: 'later').perform

      assert_in_delta Time.zone.now.to_f, @post.reload.scheduled_for.to_f, 1
    end
  end

  test 'schedules one hour after the latest approved cutoff' do
    latest = posts(:one)
    travel_to Time.zone.parse('2026-08-12 10:00:00') do
      Post.approved.update_all(
        approved_at: Time.zone.parse('2026-08-11 09:00:00'),
        scheduled_for: nil
      )
      latest.update!(
        approved_at: Time.zone.parse('2026-08-12 09:00:00'),
        scheduled_for: 3.hours.from_now
      )
      PostApprovalScheduler.new(post: @post, admin: @admin, mode: 'later').perform

      assert_equal latest.scheduled_for + 1.hour, @post.reload.scheduled_for
    end
  end
end
