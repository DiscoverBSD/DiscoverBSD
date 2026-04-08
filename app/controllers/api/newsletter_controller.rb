module Api
  class NewsletterController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_api_token

    def show
      service = NextPostsService.new(minimum_of_posts: 1, end_date: 1.day.ago, number_of_days: 6)
      result = service.perform

      if result.empty?
        render json: { error: "No posts found" }, status: :not_found
        return
      end

      posts = result.group_by { |post| post.newsletter_part }
      newsletter_service = NewsletterMarkdownService.new(posts)
      markdown = newsletter_service.newsletter_markdown
      issue_number = newsletter_service.fetch_new_newsletter_number

      if issue_number.nil?
        render json: { error: "Failed to fetch issue number" }, status: :service_unavailable
        return
      end

      render json: {
        issue_number: issue_number,
        markdown: markdown
      }
    end

    private

    def authenticate_api_token
      token = request.headers["Authorization"]&.delete_prefix("Bearer ")
      expected = ENV["NEWSLETTER_API_TOKEN"]
      unless token.present? && expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
