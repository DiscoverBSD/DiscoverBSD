require 'test_helper'

class NewsletterMarkdownServiceTest < ActiveSupport::TestCase
  def build_post(title:, url:, description:, newsletter_part:)
    Post.new(
      title: title,
      url: url,
      description: description,
      newsletter_part: newsletter_part,
      slug: SecureRandom.hex(5),
      author: users(:one)
    )
  end

  def build_service(posts_hash)
    # Inject a fake client so tests don't depend on OmniAI::Mistral::Client initialization
    fake_client = Object.new
    service = NewsletterMarkdownService.new(posts_hash, client: fake_client)
    service.define_singleton_method(:newsletter_summary) { |_content| "Summary text" }
    service.define_singleton_method(:fetch_new_newsletter_number) { 100 }
    service
  end

  test "newsletter_content does not produce consecutive blank lines" do
    posts = {
      'releases' => [
        build_post(title: "Release 1", url: "https://example.com/r1", description: "Desc for release 1.", newsletter_part: "releases")
      ],
      'bsdsec' => [],
      'news' => [
        build_post(title: "News 1", url: "https://example.com/n1", description: "Desc for news 1.", newsletter_part: "news"),
        build_post(title: "News 2", url: "https://example.com/n2", description: "Desc for news 2.", newsletter_part: "news")
      ],
      'tutorials' => [
        build_post(title: "Tutorial 1", url: "https://example.com/t1", description: "Desc for tutorial 1.", newsletter_part: "tutorials")
      ]
    }

    service = build_service(posts)
    content = service.newsletter_content

    assert_no_match(/\n{3,}/, content, "Content should not contain consecutive blank lines (3+ newlines in a row)")
    assert_no_match(/\r/, content, "Content should not contain carriage returns")
    assert_no_match(/\A\n/, content, "Content should not start with a newline")
    assert_no_match(/\n\z/, content, "Content should not end with a newline")
  end

  test "newsletter_markdown does not produce consecutive blank lines in generated sections" do
    posts = {
      'releases' => [
        build_post(title: "Release 1", url: "https://example.com/r1", description: "Desc for release 1.", newsletter_part: "releases")
      ],
      'bsdsec' => [],
      'news' => [
        build_post(title: "News 1", url: "https://example.com/n1", description: "Desc for news 1.", newsletter_part: "news")
      ],
      'tutorials' => [
        build_post(title: "Tutorial 1", url: "https://example.com/t1", description: "Desc for tutorial 1.", newsletter_part: "tutorials")
      ]
    }

    service = build_service(posts)
    markdown = service.newsletter_markdown

    # The static footer has intentional blank lines between paragraphs (exactly one blank line).
    # But there should never be 3+ consecutive newlines (double blank lines).
    assert_no_match(/\n{3,}/, markdown, "Markdown should not contain consecutive blank lines (3+ newlines in a row)")
    assert_no_match(/\r/, markdown, "Markdown should not contain carriage returns")
  end

  test "newsletter_content includes only non-empty section headers when all sections are empty" do
    posts = {
      'releases' => [],
      'bsdsec' => [],
      'news' => [],
      'tutorials' => []
    }

    service = build_service(posts)
    content = service.newsletter_content

    assert_includes content, "## Releases"
    assert_includes content, "## BSDSec"
    assert_not_includes content, "## News"
    assert_not_includes content, "## Tutorials"
  end

  test "newsletter_content includes News and Tutorials headers when they have posts" do
    posts = {
      'releases' => [],
      'bsdsec' => [],
      'news' => [
        build_post(title: "News 1", url: "https://example.com/n1", description: "News desc.", newsletter_part: "news")
      ],
      'tutorials' => [
        build_post(title: "Tutorial 1", url: "https://example.com/t1", description: "Tutorial desc.", newsletter_part: "tutorials")
      ]
    }

    service = build_service(posts)
    content = service.newsletter_content

    assert_includes content, "## News"
    assert_includes content, "## Tutorials"
  end

  test "newsletter_content shows fallback text when no releases" do
    posts = { 'releases' => [], 'bsdsec' => [], 'news' => [], 'tutorials' => [] }
    service = build_service(posts)
    content = service.newsletter_content

    assert_includes content, "No releases."
    assert_match(/## Releases\n\nNo releases\./, content, "Should have blank line between header and fallback text")
  end

  test "newsletter_content shows fallback text when no bsdsec posts" do
    posts = { 'releases' => [], 'bsdsec' => [], 'news' => [], 'tutorials' => [] }
    service = build_service(posts)
    content = service.newsletter_content

    assert_includes content, "No security announcements."
    assert_includes content, "As always, it's worth following [BSDSec]"
  end

  test "newsletter_content separates posts with single blank lines" do
    posts = {
      'releases' => [],
      'bsdsec' => [],
      'news' => [
        build_post(title: "News 1", url: "https://example.com/n1", description: "Desc 1.", newsletter_part: "news"),
        build_post(title: "News 2", url: "https://example.com/n2", description: "Desc 2.", newsletter_part: "news"),
        build_post(title: "News 3", url: "https://example.com/n3", description: "Desc 3.", newsletter_part: "news")
      ],
      'tutorials' => []
    }

    service = build_service(posts)
    content = service.newsletter_content

    # Posts within a section should be separated by exactly one blank line
    assert_includes content, "Desc 1.\n\n[News 2]"
    assert_includes content, "Desc 2.\n\n[News 3]"
  end

  test "newsletter_content separates sections with single blank lines" do
    posts = {
      'releases' => [
        build_post(title: "Release 1", url: "https://example.com/r1", description: "Release desc.", newsletter_part: "releases")
      ],
      'bsdsec' => [
        build_post(title: "Security 1", url: "https://example.com/s1", description: "Security desc.", newsletter_part: "bsdsec")
      ],
      'news' => [
        build_post(title: "News 1", url: "https://example.com/n1", description: "News desc.", newsletter_part: "news")
      ],
      'tutorials' => [
        build_post(title: "Tutorial 1", url: "https://example.com/t1", description: "Tutorial desc.", newsletter_part: "tutorials")
      ]
    }

    service = build_service(posts)
    content = service.newsletter_content

    # Each section transition should have exactly one blank line (two \n)
    assert_match(/Release desc\.\n\n## BSDSec/, content, "Should have one blank line between Releases and BSDSec")
    assert_match(/available\.\n\n## News/, content, "Should have one blank line between BSDSec and News")
    assert_match(/News desc\.\n\n## Tutorials/, content, "Should have one blank line between News and Tutorials")
  end

  test "newsletter_content includes main posts before sections" do
    posts = {
      'main' => [
        build_post(title: "Main Post", url: "https://example.com/main", description: "Main description.", newsletter_part: "main")
      ],
      'releases' => [],
      'bsdsec' => [],
      'news' => [],
      'tutorials' => []
    }

    service = build_service(posts)
    content = service.newsletter_content

    assert_match(/Main Post.*## Releases/m, content, "Main posts should appear before Releases section")
    assert_includes content, "[Main Post](https://example.com/main?utm_source=bsdweekly)\nMain description."
  end
end
