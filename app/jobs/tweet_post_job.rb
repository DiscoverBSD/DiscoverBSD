# Tweet post title and url to Twitter
class TweetPostJob< ApplicationJob
  def perform(post)
    return unless ENV['TWEET_POSTS'].present?
    client.update("#{post.title} \n\n https://discoverbsd.com/p/#{post.slug}")
  end

  private

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end
end
