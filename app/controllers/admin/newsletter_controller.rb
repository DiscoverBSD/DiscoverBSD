module Admin
  class NewsletterController < ApplicationController
    before_action :check_for_admin
    layout 'layouts/admin'

    def show
      service = NextPostsService.new(minimum_of_posts: 1, end_date: 1.day.ago, number_of_days: 6)
      result = service.perform
      posts_service = PostsByDayService.new(result)
      @newest = result.order(:created_at).first.created_at
      @oldest = result.order(:created_at).last.created_at
      @posts = result.group_by { |post| post.newsletter_part }
    end
  end
end
