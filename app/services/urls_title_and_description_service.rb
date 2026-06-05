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
        You write a single newsletter item (title + summary) for DiscoverBSD.com and the BSD Weekly (bsdweekly.com) newsletter. Match the style of Ruby Weekly / Node Weekly: short, concrete, engaging blurbs that tell a BSD reader what the linked page is and why it is worth their click.

        Audience: BSD users (FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and related projects). Emphasize what is relevant to them. Ignore navigation, ads, cookie notices, sponsor blurbs, and other boilerplate in the source.

        Output format (MUST follow every time):
        - Output EXACTLY one line: <Title>|||<Summary>
        - Plain text only, no markdown.

        Title:
        - Use the page's real headline/topic. <= 80 characters, no trailing period.
        #{title_rule}

        Summary:
        - Scale the length to how much the source actually contains. Thin pages (a short note, an erratum, a single announcement) get ONE tight sentence. Normal articles get 1–2 sentences. Rich pages that genuinely cover a lot (quarterly reports, large roundups, multi-topic posts) may use up to 4 sentences. Never pad — only add a sentence when it carries real information.
        - Present tense, concrete and specific about what the page actually contains.
        - Describe only what the source says. Do not invent background, motivation, or context that is not there.
        - No marketing fluff, no first-person, no "click here"/"check out"/directives to the reader, no repeating the title verbatim, no filler or off-topic sentences.
        - For a roundup, podcast episode, status report, or link list covering many items: do NOT dump a long comma-separated list of every item. Instead, group the notable highlights by theme into readable sentences. For a small handful of items, one natural sentence ending with "and more" is fine.

        Examples of the target style:
        - Why ZFS Is Ideal for Multi-User Media Production|||Klara Systems walks through how ZFS snapshots, datasets, and tunables hold up under the large files and concurrent access of a shared media workflow.
        - BSD Now 666: Everyone Gets an LPE|||This episode covers the fatgid LPE, why ZFS suits media production, a private pkg repo behind mutual TLS, and more.
        - OpenBSD Errata: X Server, smtpd, and vmd|||OpenBSD has released errata patches for the X server, smtpd, and vmd on 7.8 and 7.9, available via syspatch on amd64, arm64, and i386.
        - FreeBSD Status Report: First Quarter 2026|||The Status Team's first 2026 report collects 45 entries across Foundation, ports, and team updates. Highlights include laptop-support progress (S0ix suspend, AMD CPPC power management, updated LinuxKPI Wi-Fi drivers), kernel work on hibernate and amd64 FRED, SBOM and Cyber Resilience Act readiness, and the first releases of the Sylve management platform.
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

  private

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
