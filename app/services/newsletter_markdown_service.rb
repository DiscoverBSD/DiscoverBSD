# Generate markdown for the newsletter
class NewsletterMarkdownService
include ApplicationHelper
  def initialize(posts, client: nil)
    @posts = posts
    @client = client || OmniAI::Mistral::Client.new
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
    sections = []

    if @posts['main'].present?
      main_text = @posts['main'].map do |post|
        "[#{post.title}](#{bsdweekly_utm_source_url(post.url)})\n#{post.description}"
      end.join("\n\n")
      sections << main_text
    end

    releases = "## Releases\n"
    if @posts['releases'].present?
      releases += @posts['releases'].map do |post|
        "[#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description}"
      end.join("\n\n")
    else
      releases += "\nNo releases."
    end
    sections << releases

    bsdsec = "## BSDSec\n"
    if @posts['bsdsec'].present?
      bsdsec += @posts['bsdsec'].map do |post|
        "[#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description}"
      end.join("\n\n")
    else
      bsdsec += "\nNo security announcements."
    end
    bsdsec += "\n\nAs always, it's worth following [BSDSec](https://bsdsec.net). [RSS feed](https://bsdsec.net/articles.atom) available."
    sections << bsdsec

    if @posts['news'].present?
      news = "## News\n"
      news += @posts['news'].map do |post|
        "[#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description}"
      end.join("\n\n")
      sections << news
    end

    if @posts['tutorials'].present?
      tutorials = "## Tutorials\n"
      tutorials += @posts['tutorials'].map do |post|
        "[#{post.title}](#{bsdweekly_utm_source_url(post.url)}): #{post.description}"
      end.join("\n\n")
      sections << tutorials
    end

    sections.map(&:rstrip).join("\n\n")
  end

  def fetch_new_newsletter_number
    @issue_number ||= begin
      uri = URI.parse('https://bsdweekly.com/issues.json')
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body.encode('UTF-8', invalid: :replace, undef: :replace))['posts'][0]['slug'].to_i + 1
      end
    rescue StandardError => e
      nil
    end
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
    "Summary generation failed: #{e.message}. Please write the summary manually."
  end

end
