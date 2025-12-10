Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], 
    scope: 'read:user',
    provider_ignores_state: Rails.env.development?
end
OmniAuth.config.logger = Rails.logger
