# Tweet post title and url to Twitter
class TweetPostJob< ApplicationJob
  def perform(post)
    return unless ENV['TWEET_POSTS'].present?
    payload = { text: "#{post.title} \n\nhttps://discoverbsd.com/p/#{post.slug}" }.to_json
    client.post('tweets', payload)
  end

  private

  def client
    x_credentials = {
      api_key: ENV['TWITTER_CONSUMER_KEY'],
      api_key_secret: ENV['TWITTER_CONSUMER_SECRET'],
      access_token: ENV['TWITTER_ACCESS_TOKEN'],
      access_token_secret: ENV['TWITTER_ACCESS_SECRET']
    }
    @client ||= X::Client.new(**x_credentials)
  end
end
