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

    def schedule_approval
      post = Post.find(params[:id])
      post.assign_attributes(approval_params)

      if post.valid?
        PostApprovalScheduler.new(
          post: post, admin: current_user, mode: requested_schedule_mode
        ).perform
        render json: {}, status: 200
      else
        render json: {
          errors: "There seems to be some errors: #{post.errors.full_messages.join(', ')}"
        }, status: 422
      end
    end

    private

    def approval_params
      params.require(:post).permit(
        :title, :url, :description, :newsletter_part
      )
    end

    def requested_schedule_mode
      params.require(:post).permit(:schedule_mode)[:schedule_mode]
    end

    def post_params
      params.require(:post).permit(:title, :url, :description,
        :approved, :approved_by_id, :approved_at,
        :declined, :declined_by_id, :declined_at,
      :newsletter_part)
    end
  end
end
