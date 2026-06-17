# This service is used to get the title and description of the url's content.
# Get the url content and generate title and description with AI
class UrlsTitleAndDescriptionService
  # Cap how much page text is sent to the model. Raw HTML for a single page can
  # be hundreds of KB; trimming to readable text keeps requests well under
  # Mistral's per-minute token limits.
  MAX_CONTENT_CHARS = 20_000

  def initialize(url)
    @url = url
    @client = OmniAI::Mistral::Client.new
    @errors = []
  end

  def fetch_url_content
    uri = SafeUrl.new(@url).uri
    unless uri
      @errors << 'This URL cannot be fetched.'
      return
    end

    response = Net::HTTP.get_response(uri)
    response.body.encode('UTF-8', invalid: :replace, undef: :replace) if response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    @errors << e.message
    nil
  end

  def generate_title_and_description
    completion = @client.chat do |prompt|
      prompt.system <<~SYSTEM
        You write a single newsletter item (title + summary) for DiscoverBSD.com and the BSD Weekly (bsdweekly.com) newsletter. Match the style of Ruby Weekly / Node Weekly: short, concrete, engaging blurbs that tell a BSD reader what the linked page is and why it is worth their click.

        Audience: BSD users (FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and related projects). Emphasize what is relevant to them. Ignore navigation, ads, cookie notices, sponsor blurbs, and other boilerplate in the source.

        Output format (MUST follow every time):
        - Output EXACTLY one line: <Title>|||<Summary>
        - Plain text only, no markdown.

        Title:
        - Use the page's real headline/topic. <= 80 characters, no trailing period.
        - If the page is a news digest or link roundup (e.g. titles like "Valuable News", "Weekly", "Digest", "Roundup", "Linkdump", "In Other BSDs", or a flat list of many one-line links with no main article), use the page's OWN title (such as "Valuable News - 2026/06/08"). Do NOT pick one item from the list as the title.
        #{title_rule}

        Summary:
        - Scale the length to how much the source actually contains. Thin pages (a short note, an erratum, a single announcement) get ONE tight sentence. Normal articles get 1–2 sentences. Rich pages that genuinely cover a lot (quarterly reports, large roundups, multi-topic posts) may use up to 4 sentences. Never pad — only add a sentence when it carries real information.
        - Present tense, concrete and specific about what the page actually contains.
        - Describe only what the source says. Do not invent background, motivation, or context that is not there.
        - No marketing fluff, no first-person, no "click here"/"check out"/directives to the reader, no repeating the title verbatim, no filler or off-topic sentences.
        - For a roundup, podcast episode, status report, news digest, or link list covering many items: do NOT pick a single item and summarize only that, and do NOT dump a long comma-separated list of every item. Instead, name a few of the most BSD-relevant highlights grouped into readable sentences. For a small handful of items, one natural sentence ending with "and more" is fine.
        - When the page is a digest or link list, first identify which items are BSD-relevant (FreeBSD, OpenBSD, NetBSD, DragonFly BSD, ZFS, pf, ports, etc.) and ignore the rest (general Linux, npm, off-topic posts). Then write the summary from those BSD items only. A single item must never stand in for the whole digest.

        Write like a human, not like an AI. Avoid these AI-writing tells:
        - No em dashes (—). Use commas, parentheses, or separate sentences. Prefer plain hyphenated lists or "such as".
        - Use straight quotes (') and ("), never curly quotes ('' "").
        - Don't inflate significance: avoid "marks a milestone", "underscores", "highlights its importance", "pivotal", "landmark", "key step", "reflects a broader trend", or any "why this matters" editorializing the source didn't state.
        - Avoid AI-vocabulary words: delve, leverage, robust, seamless, crucial, vital, boasts, showcase, foster, enhance, intricate, tapestry, realm, landscape (figurative), comprehensive, notably, additionally.
        - Use plain verbs. Prefer "is/are/has/adds" over "serves as", "stands as", "boasts", "features", "represents".
        - No rule-of-three padding (adjective, adjective, adjective) and no "not just X, but Y" parallelisms.
        - Don't end sentences with a trailing "-ing" clause that editorializes (e.g. "...releasing new builds, strengthening its security posture"). State the facts plainly.
        - No vague attributions ("observers note", "experts say") unless the source names them.

        Examples of the target style:
        - Why ZFS Is Ideal for Multi-User Media Production|||Klara Systems walks through how ZFS snapshots, datasets, and tunables hold up under the large files and concurrent access of a shared media workflow.
        - OpenBSD Errata: X Server, smtpd, and vmd|||OpenBSD has released errata patches for the X server, smtpd, and vmd on 7.8 and 7.9, available via syspatch on amd64, arm64, and i386.
        - Valuable News - 2026/06/08|||This week's roundup covers FreeBSD 15.1-RC3, OpenBSD updating clang/lld to 22.1.6 and adding boot-time relinking for httpd and smtpd, NetBSD's GSoC 2026 contributors, an analysis of a compromised pfSense firewall, and more.
        SYSTEM
      prompt.user do |message|
        message.text("The page content is: #{page_text}")
      end
    end
    title, description = completion.text.split("|||")
    { title: title, description: description, errors: @errors }
  rescue OmniAI::HTTPError => e
    @errors << JSON.parse(e.response.body)["message"]
    { title: nil, description: nil, errors: @errors }
  end

  private

  # Fetch the page and reduce it to readable text: drop scripts, styles, and
  # other non-content nodes, collapse whitespace, and cap the length so a large
  # page does not blow past the model's token limits.
  def page_text
    html = fetch_url_content
    return if html.nil?

    doc = Nokogiri::HTML(html)
    title = doc.at('title')&.text.to_s.strip
    doc.search('script, style, noscript, svg, iframe, template, link, meta').remove
    body = doc.at('body') || doc
    text = body.text.gsub(/\s+/, ' ').strip
    text = "Title: #{title}\n\n#{text}" unless title.empty?
    text[0, MAX_CONTENT_CHARS]
  end

  def title_rule
    if bsdsec_source?
      '- This page is from BSDSec: use its exact page title/headline verbatim, with no rewording.'
    else
      ''
    end
  end

  def bsdsec_source?
    URI.parse(@url).host.to_s.downcase.delete_prefix('www.') == 'bsdsec.net'
  rescue URI::InvalidURIError
    false
  end
end
