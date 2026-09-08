# Retries a chat completion on @fallback_client if @client raises.
module AiChatFallback
  # model: only applies to the primary client; the fallback provider uses its own default model.
  def chat_with_fallback(model: nil, &block)
    opts = model ? { model: model } : {}
    @client.chat(**opts, &block)
  rescue StandardError
    raise unless @fallback_client

    @fallback_client.chat(&block)
  end
end
