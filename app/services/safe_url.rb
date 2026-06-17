require 'ipaddr'
require 'resolv'
require 'uri'

# Validates a user-supplied URL before the application fetches it server-side.
# Guards against SSRF by allowing only https and rejecting hosts that resolve
# to loopback, private, link-local, or otherwise internal addresses (e.g.
# 127.0.0.1, 10.0.0.0/8, 169.254.169.254, and IPv6 unique-local/link-local).
#
# Note: this resolves and checks the host but does not pin the connection to the
# resolved IP, so it does not fully close DNS-rebinding (TOCTOU). It blocks the
# common, high-impact cases.
class SafeUrl
  ALLOWED_SCHEMES = %w[https].freeze

  # Ranges not already covered by IPAddr#loopback?/#private?/#link_local?.
  EXTRA_BLOCKED_RANGES = [
    IPAddr.new('0.0.0.0/8'),     # "this" network
    IPAddr.new('100.64.0.0/10'), # carrier-grade NAT
    IPAddr.new('::/128'),        # unspecified
    IPAddr.new('::ffff:0:0/96')  # IPv4-mapped IPv6
  ].freeze

  def initialize(url)
    @url = url.to_s
  end

  # @return [URI, nil] the parsed URI when safe to fetch, otherwise nil
  def uri
    parsed = URI.parse(@url)
    host = parsed.hostname
    return unless ALLOWED_SCHEMES.include?(parsed.scheme)
    return if host.nil? || host.empty?

    ips = resolve(host)
    return if ips.empty? || ips.any? { |ip| internal?(ip) }

    parsed
  rescue URI::InvalidURIError
    nil
  end

  def safe?
    !uri.nil?
  end

  private

  def resolve(host)
    return [host] if ip_literal?(host)

    Resolv.getaddresses(host)
  rescue StandardError
    []
  end

  def ip_literal?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    false
  end

  def internal?(address)
    ip = IPAddr.new(address)
    ip.loopback? || ip.private? || ip.link_local? ||
      EXTRA_BLOCKED_RANGES.any? { |range| range.include?(ip) }
  rescue IPAddr::InvalidAddressError
    true
  end
end
