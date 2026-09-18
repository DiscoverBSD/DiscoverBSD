# Retries a chat completion on @fallback_client if @client raises.
module AiChatFallback
  class ProviderError < StandardError
    attr_reader :failures

    def initialize(failures)
      @failures = failures
      super(failures.map { |failure| "#{failure[:provider]}: #{failure[:error].message}" }.join('; '))
    end
  end

  # model: only applies to the primary client; the fallback provider uses its own default model.
  def chat_with_fallback(
    model: nil,
    provider_name: 'Google Gemini',
    fallback_provider_name: 'Mistral',
    &block
  )
    opts = model ? { model: model } : {}
    @client.chat(**opts, &block)
  rescue StandardError => primary_error
    raise ProviderError.new([{ provider: provider_name, error: primary_error }]) unless @fallback_client

    begin
      @fallback_client.chat(&block)
    rescue StandardError => fallback_error
      raise ProviderError.new([
        { provider: provider_name, error: primary_error },
        { provider: fallback_provider_name, error: fallback_error }
      ])
    end
  end
end
