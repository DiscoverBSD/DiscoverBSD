module Admin
  class DashboardController < ApplicationController
    before_action :check_for_admin
    layout 'layouts/admin'

    def show
      @pending_posts = Post.not_yet_approved.order(created_at: :asc)
      @scheduled_posts = Post.scheduled
    end
  end
end
