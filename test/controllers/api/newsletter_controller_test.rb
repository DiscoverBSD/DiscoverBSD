require 'test_helper'

class Api::NewsletterControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_token = ENV["NEWSLETTER_API_TOKEN"]
    ENV["NEWSLETTER_API_TOKEN"] = "test-secret-token"
  end

  teardown do
    ENV["NEWSLETTER_API_TOKEN"] = @original_token
  end

  test "returns unauthorized without token" do
    get api_newsletter_url
    assert_response :unauthorized
    assert_equal "Unauthorized", response.parsed_body["error"]
  end

  test "returns unauthorized with wrong token" do
    get api_newsletter_url, headers: { "Authorization" => "Bearer wrong-token" }
    assert_response :unauthorized
  end

  test "returns newsletter markdown with valid token" do
    fake_service = Object.new
    fake_service.define_singleton_method(:newsletter_markdown) { "# Test Newsletter\nSome content" }
    fake_service.define_singleton_method(:fetch_new_newsletter_number) { 42 }

    original_new = NewsletterMarkdownService.method(:new)
    NewsletterMarkdownService.define_singleton_method(:new) { |*_args| fake_service }

    begin
      get api_newsletter_url, headers: { "Authorization" => "Bearer test-secret-token" }
    ensure
      NewsletterMarkdownService.define_singleton_method(:new, original_new)
    end

    assert_response :success
    body = response.parsed_body
    assert_equal "# Test Newsletter\nSome content", body["markdown"]
    assert_equal 42, body["issue_number"]
  end

  test "returns not found when no posts exist" do
    empty_relation = Post.none

    original_perform = NextPostsService.instance_method(:perform)
    NextPostsService.define_method(:perform) { empty_relation }

    begin
      get api_newsletter_url, headers: { "Authorization" => "Bearer test-secret-token" }
    ensure
      NextPostsService.define_method(:perform, original_perform)
    end

    assert_response :not_found
    assert_equal "No posts found", response.parsed_body["error"]
  end
end
