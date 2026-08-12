class PostApprovalScheduler
  MODES = %w[now later].freeze

  def initialize(post:, admin:, mode:)
    @post = post
    @admin = admin
    @mode = mode.to_s
  end

  def perform
    raise ArgumentError, "Unsupported scheduling mode: #{@mode}" unless MODES.include?(@mode)

    scheduled_for = scheduled_time

    Post.transaction do
      @post.update!(
        approved: true,
        approved_at: Time.zone.now,
        approved_by: @admin,
        scheduled_for: scheduled_for
      )

      TootPostJob.set(wait_until: scheduled_for).perform_later(@post)
    end

    @post
  end

  private

  def scheduled_time
    return Time.zone.now if @mode == 'now'

    latest_scheduled_for = Post.approved.where.not(id: @post.id).maximum(:scheduled_for)
    latest_approved_at = Post.approved.where.not(id: @post.id).maximum(:approved_at)
    latest_cutoff = [latest_scheduled_for, latest_approved_at].compact.max

    return Time.zone.now unless latest_cutoff

    [Time.zone.now, latest_cutoff + 1.hour].max
  end
end
