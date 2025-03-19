# Generate markdown for the newsletter
class NewsletterMarkdownService
include ApplicationHelper
  def initialize(posts)
    @posts = posts
    @client = OmniAI::Mistral::Client.new
  end

  def newsletter_markdown
    content = newsletter_content
    summary = newsletter_summary(content)
    markdown = <<~MARKDOWN
      ---
      title: Issue #{fetch_new_newsletter_number}
      date: #{Time.now.utc.iso8601}
      ---
      #{summary}
      <!-- more -->
      #{content}
      ### Did we miss anything?
      This newsletter is made from your content on [DiscoverBSD](https://discoverbsd.com) and [BSDSec](https://bsdsec.net). Submit the stuff we missed so it can appear next time.
      
      Do you have an OSS BSD-related project that you would like to showcase in BSD Weekly? Reply to sender and we can showcase you as a sponsor of an issue (for free).
      
      **Do you know anyone who would like this newsletter? Consider forwarding and tell them to subscribe.**
      
      Thanks for reading and see you next week! Stay safe!
    MARKDOWN

    markdown
  end

  def newsletter_content
    markdown = ""
    if @posts['main'].present?
      @posts['main'].each do |post|
        markdown += <<~MARKDOWN
          [#{post.title}](#{bsdweekly_utm_source_url(post.url)})
          #{post.description} \r\n
        MARKDOWN
      end
    end

    markdown += "\r\n## Releases\r\n"
    if @posts['releases'].present?
      @posts['releases'].each do |post|
        markdown += <<~MARKDOWN
          [#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description} \r\n
        MARKDOWN
      end
    else 
      markdown += "\r\nNo releases.\r\n"
    end
    markdown += "\r\n## BSDSec\r\n"
    if @posts['bsdsec'].present?
      @posts['bsdsec'].each do |post|
        markdown += <<~MARKDOWN
          [#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description} \r\n
        MARKDOWN
      end
    else 
      markdown += "\r\nNo security announcements.\r\n"
    end
    markdown += "As always, it's worth following [BSDSec](https://bsdsec.net). [RSS feed](https://bsdsec.net/articles.atom) available.\r\n"
    markdown += "\r\n## News\r\n"
    if @posts['news'].present?
      @posts['news'].each do |post|
        markdown += <<~MARKDOWN
          [#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description} \r\n
        MARKDOWN
      end
    end
    markdown += "## Tutorials\r\n"
    if @posts['tutorials'].present?
      @posts['tutorials'].each do |post|
        markdown += <<~MARKDOWN
          [#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description} \r\n
        MARKDOWN
      end
    end
    markdown
  end

  def fetch_new_newsletter_number
    uri = URI.parse('https://bsdweekly.com/issues.json')
    response = Net::HTTP.get_response(uri)
  
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body.encode('UTF-8', invalid: :replace, undef: :replace))['posts'][0]['slug'].to_i + 1
    end
  rescue StandardError => e
    'Error'
  end

  def newsletter_summary(content)
    completion = @client.chat do |prompt|
      prompt.system <<~SYSTEM
        Task:  

        1. Analyze provided content.
        2. Generate Summary:  
            - Summarize the key points of the content in one sentence of maximum 150 characters.
            - Example: DiscoverBSD updates, NetBSD satelites, BSD 2024 highlights and more.
            - pick maximum of 3 posts altogether
            - always use "and more" at the end of the summary
            - Do not specifically mention if no releases or security announcements are present.
        3. Output Format: Text of the summary

        Return only plain text, no HTML or other formatting that could be used to hijack the website.
        SYSTEM
      prompt.user do |message|
        message.text("The content is: #{content}")
      end
    end
    completion.text
  rescue StandardError => e
    'Error'
  end

end
