module Admin
  class DashboardController < ApplicationController
    before_action :check_for_admin
    layout 'layouts/admin'

    def show
      @posts = Post.not_yet_approved.order(created_at: :asc)
    end
  end
end
