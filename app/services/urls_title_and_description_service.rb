# This service is used to get the title and description of the url's content.
# Getthe url content and generate title and description with AI
class UrlsTitleAndDescriptionService
  attr_reader :errors 
  def initialize(url)
    @url = url
    @client = OmniAI::Mistral::Client.new
  end

  def fetch_url_content
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)
  
    if response.is_a?(Net::HTTPSuccess)
      response.body.encode('UTF-8', invalid: :replace, undef: :replace)
    end
  rescue StandardError => e
    puts e.message
  end

  def generate_title_and_description
    completion = @client.chat do |prompt|
      prompt.system <<~SYSTEM
        Task:  

        1. Analyze HTML content.
        2. Generate Title:  
            - Title should be informative and relevant to the content.
            - Target length: under 80 characters.
        3. Generate Summary:  
            - Summarize the key points of the content in 3-5 concise sentences.
            - Highlight what the article or resource is about and why someone interested in BSD might find it valuable.
        4. Output Format: Title|||Summary

        Additional Considerations:  
        - Identify and avoid clickbait-style titles. 
        - Use keywords naturally throughout the title and summary. 
        - Consider the target audience might be beginners but mostly experienced users when crafting the summary. 

        Return only plain text, no HTML or other formatting that could be used to hijack the website.
        When no HTML is provided, return an error message "Please, provide an URL with HTML content."
        SYSTEM
      prompt.user do |message|
        message.text("The HTML content is: #{fetch_url_content}")
      end
    end
    completion.text.split("|||")
  end
end
