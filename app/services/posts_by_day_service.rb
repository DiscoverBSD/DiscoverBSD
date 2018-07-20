# Values for `posts/by_day` partial
class PostsByDayService
  def initialize(posts)
    @posts = posts
  end

  def next_date_to_load
    return unless @posts.present?
    (@posts.last.created_at - 1.day).strftime('%F')
  end

  def group_by_day
    return [] unless @posts.present?
    @posts.group_by { |post| post.created_at.strftime('%F') }
  end
end
