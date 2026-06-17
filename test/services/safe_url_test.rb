require 'test_helper'
require 'resolv'

class SafeUrlTest < ActiveSupport::TestCase
  test 'allows public https URLs' do
    assert SafeUrl.new('https://1.1.1.1/path').safe?
    assert SafeUrl.new('https://93.184.216.34/').safe?
  end

  test 'rejects http and other non-https schemes' do
    refute SafeUrl.new('http://1.1.1.1/').safe?
    refute SafeUrl.new('ftp://example.com/file').safe?
    refute SafeUrl.new('file:///etc/passwd').safe?
    refute SafeUrl.new('javascript:alert(1)').safe?
  end

  test 'rejects malformed or empty input' do
    refute SafeUrl.new('not a url').safe?
    refute SafeUrl.new('').safe?
    refute SafeUrl.new('https://').safe?
  end

  test 'blocks loopback addresses' do
    refute SafeUrl.new('https://127.0.0.1/').safe?
    refute SafeUrl.new('https://[::1]/').safe?
  end

  test 'blocks private network addresses' do
    refute SafeUrl.new('https://10.0.0.1/').safe?
    refute SafeUrl.new('https://172.16.5.4/').safe?
    refute SafeUrl.new('https://192.168.1.1/').safe?
  end

  test 'blocks link-local and cloud metadata addresses' do
    refute SafeUrl.new('https://169.254.169.254/latest/meta-data/').safe?
  end

  test 'blocks unspecified and IPv4-mapped addresses' do
    refute SafeUrl.new('https://0.0.0.0/').safe?
    refute SafeUrl.new('https://[::]/').safe?
    refute SafeUrl.new('https://[::ffff:169.254.169.254]/').safe?
  end

  test 'blocks carrier-grade NAT addresses' do
    refute SafeUrl.new('https://100.64.0.1/').safe?
  end

  test 'blocks IPv6 unique-local and link-local addresses' do
    refute SafeUrl.new('https://[fc00::1]/').safe?
    refute SafeUrl.new('https://[fd00::1]/').safe?
    refute SafeUrl.new('https://[fe80::1]/').safe?
  end

  test 'blocks hostnames that resolve to a private address' do
    Resolv.stub(:getaddresses, ['10.0.0.5']) do
      refute SafeUrl.new('https://internal.example.com/').safe?
    end
  end

  test 'allows hostnames that resolve to a public address' do
    Resolv.stub(:getaddresses, ['93.184.216.34']) do
      assert SafeUrl.new('https://example.com/').safe?
    end
  end

  test 'blocks hostnames that cannot be resolved' do
    Resolv.stub(:getaddresses, []) do
      refute SafeUrl.new('https://nonexistent.invalid/').safe?
    end
  end
end
