# Toot post title and url to Mastodon
class TootPostJob < ApplicationJob
  def perform(post)
    return unless ENV['TOOT_POSTS'].present?
    client.create_status("#{post.title} \n\nhttps://discoverbsd.com/p/#{post.slug}")
  end

  private

  def client
    @client ||= Mastodon::REST::Client.new(base_url: 'https://bsd.network',
                  bearer_token: ENV['MASTODON_ACCESS_TOKEN'])
  end
end
