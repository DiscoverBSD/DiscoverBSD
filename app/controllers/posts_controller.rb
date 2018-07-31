class PostsController < ApplicationController
  def new
    @post = Post.new
    render layout: false
  end

  def create
    post = Post.create(post_params)
    if post.valid?
      render json: {
        }, status: 200
    else
      render json: {
        errors: "There seems to be some errors: #{post.errors.full_messages.join(', ')}"
      }, status: 422
    end
  end

  def by_day
    service = NextPostsService.new(minimum_of_posts: 10, end_date: Date.parse(params[:from]), number_of_days: 5)
    result = service.perform
    posts_service = PostsByDayService.new(result)
    load_posts_from = posts_service.next_date_to_load
    posts = posts_service.group_by_day
    render partial: "posts/by_day", locals: { posts: posts, load_posts_from: load_posts_from }
  end

  def feed
    @posts = Post.approved.order(created_at: :desc).limit(50)
    render 'posts/feed.atom', layout: false
  end

  private

  def post_params
    params.require(:post).permit(:title, :url, :author_id, :description)
  end
end
