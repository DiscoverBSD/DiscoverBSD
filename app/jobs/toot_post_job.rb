require 'net/http'
require 'uri'

# Toot post title and url to Mastodon
class TootPostJob < ApplicationJob
  MASTODON_API_URL = 'https://bsd.network/api/v1/statuses'

  def perform(post)
    return unless ENV['TOOT_POSTS'].present?

    post_status("#{post.title} \n\nhttps://discoverbsd.com/p/#{post.slug}", idempotency_key: "toot_post_#{post.id}")
  end

  private

  def post_status(text, idempotency_key: nil)
    uri = URI.parse(MASTODON_API_URL)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['MASTODON_ACCESS_TOKEN']}"
    request['Idempotency-Key'] = idempotency_key if idempotency_key
    request.set_form_data(status: text)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      # Status posted successfully
    when Net::HTTPUnauthorized, Net::HTTPUnprocessableEntity
      Rails.logger.error("[TootPostJob] Permanent failure: #{response.code} #{response.body}")
      Rollbar.error("[TootPostJob] Permanent failure", response_code: response.code, response_body: response.body)
    else
      raise "Mastodon API error: #{response.code} #{response.body}"
    end
  end
end
