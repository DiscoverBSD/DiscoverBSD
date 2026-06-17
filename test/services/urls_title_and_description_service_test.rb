require 'test_helper'

class UrlsTitleAndDescriptionServiceTest < ActiveSupport::TestCase
  # OmniAI::Mistral::Client.new raises without MISTRAL_API_KEY, so inject a fake
  # client. These stand-ins also keep the suite off the network: the fake client
  # never runs the chat block, and fetch_url_content is stubbed per test.
  FakeCompletion = Struct.new(:text)

  class FakeClient
    def initialize(text)
      @text = text
    end

    def chat(*_args, **_kwargs)
      FakeCompletion.new(@text)
    end
  end

  def build_service(html:, model_text: 'Title|||Summary', url: 'https://example.com/post')
    service = UrlsTitleAndDescriptionService.new(url, client: FakeClient.new(model_text))
    service.define_singleton_method(:fetch_url_content) { html }
    service
  end

  test 'page_text extracts og/meta tags when the body is rendered by JavaScript (e.g. YouTube)' do
    html = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Rick Astley - Never Gonna Give You Up - YouTube</title>
          <meta property="og:title" content="Rick Astley - Never Gonna Give You Up (Official Video)">
          <meta property="og:description" content="The official video for Never Gonna Give You Up by Rick Astley.">
          <meta name="description" content="The official video for Never Gonna Give You Up by Rick Astley.">
          <script>var ytcfg = {};</script>
        </head>
        <body><noscript>To watch this video please enable JavaScript.</noscript></body>
      </html>
    HTML

    text = build_service(html: html).send(:page_text)

    assert_includes text, 'Rick Astley - Never Gonna Give You Up (Official Video)'
    assert_includes text, 'The official video for Never Gonna Give You Up by Rick Astley.'
    refute_includes text, 'var ytcfg', 'scripts should be stripped'
    refute_includes text, 'enable JavaScript', 'noscript content should be stripped'
  end

  test 'page_text keeps the title and body text for a normal article and drops scripts/styles' do
    html = <<~HTML
      <html>
        <head><title>FreeBSD 15.1 Released</title></head>
        <body>
          <h1>FreeBSD 15.1 Released</h1>
          <p>The FreeBSD project announces the release of 15.1 with new drivers.</p>
          <style>.ad { color: red; }</style>
          <script>track();</script>
        </body>
      </html>
    HTML

    text = build_service(html: html).send(:page_text)

    assert_includes text, 'FreeBSD 15.1 Released'
    assert_includes text, 'The FreeBSD project announces the release of 15.1 with new drivers.'
    refute_includes text, 'track()', 'scripts should be stripped'
    refute_includes text, 'color: red', 'styles should be stripped'
    refute_includes text, 'og:title:', 'no meta block should appear when og/meta tags are absent'
  end

  test 'page_text caps the content at MAX_CONTENT_CHARS' do
    html = "<html><body><p>#{'a' * 30_000}</p></body></html>"

    text = build_service(html: html).send(:page_text)

    assert_operator text.length, :<=, UrlsTitleAndDescriptionService::MAX_CONTENT_CHARS
  end

  test 'page_text returns nil when the page could not be fetched' do
    assert_nil build_service(html: nil).send(:page_text)
  end

  test 'generate_title_and_description returns the parsed title and description' do
    result = build_service(
      html: '<html><body>x</body></html>',
      model_text: 'My Title|||My summary text.'
    ).generate_title_and_description

    assert_equal 'My Title', result[:title]
    assert_equal 'My summary text.', result[:description]
    assert_empty result[:errors]
  end

  test 'generate_title_and_description reports an error when the model returns no summary' do
    result = build_service(
      html: '<html><body>x</body></html>',
      model_text: 'No separator in this reply'
    ).generate_title_and_description

    assert_nil result[:title]
    assert_nil result[:description]
    assert_includes result[:errors], 'Could not extract enough readable content from this page to summarize it.'
  end
end
