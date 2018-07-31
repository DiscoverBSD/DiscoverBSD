class HomeController < ApplicationController
  def show
    service = NextPostsService.new(minimum_of_posts: 10, end_date: Time.zone.now, number_of_days: 5)
    result = service.perform
    posts_service = PostsByDayService.new(result)
    @load_posts_from = posts_service.next_date_to_load
    @posts = posts_service.group_by_day
    @post = Post.approved.find_by(slug: params[:slug]) if params[:slug].present?
    if admin?
      @waiting = Post.not_yet_approved.size
    end
  end
end
