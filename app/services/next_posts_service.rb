# Service to get next posts
#
# when we have specific day, then we want all posts from that day
#
# laod next `minimum_of_posts` posts until `end_date`
# or posts from `number_of_days`
# whichever is bigger
class NextPostsService
  def initialize(minimum_of_posts:, end_date:, number_of_days:)
    @minimum_of_posts = minimum_of_posts
    @end_date = end_date
    @number_of_days = number_of_days
  end

  def perform
    if posts_from_number_of_days.size > posts_from_minumum_of_posts.size
      posts_from_number_of_days
    else
      posts_from_minumum_of_posts
    end
  end

  private

  # posts based on number of days to use
  def posts_from_number_of_days
    end_date = @end_date.end_of_day
    start_date = (end_date - @number_of_days.days).beginning_of_day
    @posts_from_number_of_days ||= Post.approved.where(created_at: start_date..end_date).order(created_at: :desc)
  end

  # posts based on number of posts
  #  plus we also include all posts from last day
  def posts_from_minumum_of_posts
    oldest_post = Post.approved.where('created_at < ?', @end_date.beginning_of_day)
      .order(created_at: :desc)
      .limit(@minimum_of_posts).last
    return [] unless oldest_post.present?
    start_date = oldest_post.created_at.beginning_of_day
    end_date = @end_date.end_of_day
    @posts_from_minumum_of_posts ||= Post.approved.where(created_at: start_date..end_date).order(created_at: :desc)
  end
end
