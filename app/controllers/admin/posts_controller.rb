module Admin
  class PostsController < ApplicationController
    before_action :check_for_admin

    def update
      post = Post.find(params[:id])
      post.update(post_params)
      if post.valid?
        render json: {}, status: 200
      else
        render json: {
          errors: "There seems to be some errors: #{post.errors.full_messages.join(', ')}"
        }, status: 422
      end
    end

    def approve_and_tweet
      post = Post.find(params[:id])
      post.update(post_params)
      if post.valid?
        TweetPostJob.perform_later(post)
        render json: {}, status: 200
      else
        render json: {
          errors: "There seems to be some errors: #{post.errors.full_messages.join(', ')}"
        }, status: 422
      end
    end

    private

    def post_params
      params.require(:post).permit(:title, :url, :description,
        :approved, :approved_by_id, :approved_at,
        :declined, :declined_by_id, :declined_at)
    end
  end
end
