# Use a MockSocket for unit tests so that they depend only on this library,
# not on the M2X service being available or the current behavior of the service.
class MockSocketClass
  def initialize
    reset!
  end

  ##
  # Test API - These methods are to be used bt the test suite.

  attr_accessor :host
  attr_accessor :port

  def enabled?
    !!@enabled
  end

  def expect_connect(host, port)
    @expected_host = host
    @expected_port = port
  end

  def expect_request(*lines)
    @enabled = true
    @expected = lines.join("\r\n")
  end

  def prepare_response(*lines)
    @enabled = true
    @readable = lines.join("\r\n")
  end

  def verify!
    assert_equal @expected_host,    @host    if @expected_host
    assert_equal @expected_port,    @port    if @expected_port
    assert_equal @expected_written, @written if @expected_written
  end

  def reset!
    @enabled = false
    @written = ""
    @readable = ""
    @expected_host = nil
    @expected_port = nil
    @expected_written = nil
  end

  ##
  # Stubbed IO-compatibility API - These methods are to be used by the Client.

  def write(data)
    @written += data
  end

  def readline
    line_index = @readable.index("\n")
    return nil unless line_index
    read(line_index+1)
  end

  def read(count)
    data = @readable[0...count]
    @readable = @readable[count..-1]
    data
  end
end

# Create a single mock instance to be used for all tests and all Clients.
MockSocket = MockSocketClass.new

# Patch M2X::Client#new_socket to return MockSocket instead if it is enabled.
class M2X::Client
  def new_socket(host, port)
    if MockSocket.enabled?
      MockSocket.host = host
      MockSocket.port = port
      MockSocket
    else
      TCPSocket.new(host, port)
    end
  end
end

# An invalid API key to use in tests.
TEST_API_KEY = '0123456789abcdef0123456789abcdef'

assert 'Client.new' do
  subject = M2X::Client.new
  assert_equal subject.api_key,     nil
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'Client.new(api_key)' do
  subject = M2X::Client.new(TEST_API_KEY)
  assert_equal subject.api_key,     TEST_API_KEY
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'Client#get' do
  subject = M2X::Client.new(TEST_API_KEY)

  MockSocket.expect_connect('api-m2x.att.com', 80)
  MockSocket.expect_request(
    'GET /v2/status HTTP/1.1',
    'User-Agent: ' + M2X::Client::USER_AGENT,
    'X-M2X-KEY: ' + TEST_API_KEY,
    '',
  )
  MockSocket.prepare_response(
    'HTTP/1.1 200 OK',
    'Content-Type: application/json',
    'Date: Tue, 17 Mar 2015 18:00:00 GMT',
    'Server: nginx',
    'Status: 200 OK',
    'Vary: Accept',
    'X-M2x-Version: v2.14.0',
    'Content-Length: 28',
    '',
    '{"api":"OK","triggers":"OK"}',
  )

  res = subject.get '/status'

  MockSocket.verify!
  MockSocket.reset!

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status, 200
  assert_equal res.success?, true
  assert_equal res.error?, false
  assert_equal res.client_error?, false
  assert_equal res.server_error?, false
  assert_equal res.content_type, "application/json"
  assert_equal res.json, {"api"=>"OK","triggers"=>"OK"}
  assert_equal res.headers, {
    "Content-Type"=>"application/json",
    "Date"=>"Tue, 17 Mar 2015 18:00:00 GMT",
    "Server"=>"nginx",
    "Status"=>"200 OK",
    "Vary"=>"Accept",
    "X-M2x-Version"=>"v2.14.0",
    "Content-Length"=>"28"
  }
end
