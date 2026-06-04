# This service is used to get the title and description of the url's content.
# Getthe url content and generate title and description with AI
class UrlsTitleAndDescriptionService
  def initialize(url)
    @url = url
    @client = OmniAI::Mistral::Client.new
    @errors = []
  end

  def fetch_url_content
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)
  
    if response.is_a?(Net::HTTPSuccess)
      response.body.encode('UTF-8', invalid: :replace, undef: :replace)
    end
  rescue StandardError => e
    @errors << e.message
  end

  def generate_title_and_description
    completion = @client.chat do |prompt|
      prompt.system <<~SYSTEM
        Hard Constraints (MUST follow every time):
        Output EXACTLY one line containing: <Title>|||<Summary>
        Context: the title and summary appear as a single linked item on DiscoverBSD.com and in the BSD Weekly (bsdweekly.com) newsletter. Write them to quickly tell a BSD reader what the article covers and why it matters, so they can decide to click through.
        Focus: this is for a BSD-focused audience (FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and related projects). Emphasize the BSD-relevant aspects of the content. Ignore any non-BSD filler, navigation, ads, or unrelated material in the source.
        Title: <= 80 characters, no trailing period, concise and descriptive.
        Summary: 2–3 sentences covering the main BSD-relevant points of the article. Keep it tight — do not pad with minor details, and drop to 1 sentence only if the source is genuinely thin.
        Summary content: describe only what the article itself states, focusing on the most important BSD-relevant points. Do not add background, context, or general statements that are not in the source, and do not enumerate every minor item.
        Summary style: neutral, informative, no marketing fluff, no first-person, no directives to the reader, no repetition of the title verbatim, no filler or off-topic sentences.
        Formatting: give me plain text only, do not include any markdown.
        SYSTEM
      prompt.user do |message|
        message.text("The HTML content is: #{fetch_url_content}")
      end
    end
    title, description = completion.text.split("|||")
    { title: title, description: description, errors: @errors }
  rescue OmniAI::HTTPError => e
    @errors << JSON.parse(e.response.body)["message"]
    { title: nil, description: nil, errors: @errors }
  end
end
