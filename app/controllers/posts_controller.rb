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

  private

  def post_params
    params.require(:post).permit(:title, :url, :author_id, :description)
  end
end
