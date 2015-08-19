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

  def expect_request_lines(*lines)
    @enabled = true
    @expected_written = lines.join("\r\n")
  end

  def prepare_response_lines(*lines)
    @enabled = true
    @readable = lines.join("\r\n")
  end

  def expect_request(verb, path, opts={})
    headers = {
      "User-Agent" => M2X::Client::USER_AGENT,
      "X-M2X-KEY"  => TEST_API_KEY,
    }
    if opts[:json]
      body = JSON.generate(opts[:json])
      headers["Content-Type"]   = "application/json"
      headers["Content-Length"] = body.bytesize
    else
      body = ""
    end

    expect_request_lines(
      "#{verb.to_s.upcase} #{path} HTTP/1.1",
      *headers.map { |key,val| "#{key}: #{val}" },
      "",
      body
    )
  end

  def prepare_response(status, opts={})
    headers = {}
    if opts[:json]
      body = JSON.generate(opts[:json])
      headers["Content-Type"]   = "application/json"
      headers["Content-Length"] = body.bytesize
    else
      body = ""
    end

    prepare_response_lines(
      "HTTP/1.1 #{status}",
      *headers.map { |key,val| "#{key}: #{val}" },
      "",
      body
    )
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

  def mock!(request, response, &block)
    result = nil
    begin
      MockSocket.expect_request(*request)
      MockSocket.prepare_response(*response)
      result = block.call
      MockSocket.verify!
    ensure
      MockSocket.reset!
    end
    result
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
TEST_API_KEY = '8fa2e8f6f42d664355f718a90e78d31d'

##
# Test Cases

assert 'M2X::Client.new' do
  subject = M2X::Client.new
  assert_equal subject.api_key,     nil
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'M2X::Client.new(api_key)' do
  subject = M2X::Client.new(TEST_API_KEY)
  assert_equal subject.api_key,     TEST_API_KEY
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'M2X::Client#get' do
  subject = M2X::Client.new(TEST_API_KEY)

  MockSocket.expect_connect('api-m2x.att.com', 80)
  MockSocket.expect_request_lines(
    "GET /v2/status HTTP/1.1",
    "User-Agent: #{M2X::Client::USER_AGENT}",
    "X-M2X-KEY: #{TEST_API_KEY}",
    "",
    "",
  )
  MockSocket.prepare_response_lines(
    "HTTP/1.1 200 OK",
    "Content-Type: application/json",
    "Date: Tue, 17 Mar 2015 18:00:00 GMT",
    "Server: nginx",
    "Status: 200 OK",
    "Vary: Accept",
    "X-M2x-Version: v2.14.0",
    "Content-Length: 28",
    "",
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

assert 'M2X::Client#create_device' do
  subject = M2X::Client.new(TEST_API_KEY)
  params = { name:'test device', visibility:'public', description:'foo' }
  result = params.merge(id:'a2852df27102179429b3a02641594044')

  device = MockSocket.mock!(
    [:post, "/v2/devices", json:params],
    ['201 Created', json:result]
  ) {
    subject.create_device(params)
  }

  assert_true device.is_a?(M2X::Client::Device)
  assert_equal device['id'],          result[:id]
  assert_equal device['name'],        result[:name]
  assert_equal device['visibility'],  result[:visibility]
  assert_equal device['description'], result[:description]
end

assert 'M2X::Client#device' do
  subject = M2X::Client.new(TEST_API_KEY)
  result = { id:'a2852df27102179429b3a02641594044',
             name:'test device', visibility:'public', description:'foo' }

  device = MockSocket.mock!(
    [:get, "/v2/devices/#{result[:id]}"],
    ['200 OK', json:result]
  ) {
    subject.device(result[:id])
  }

  assert_true device.is_a?(M2X::Client::Device)
  assert_equal device['id'],          result[:id]
  assert_equal device['name'],        result[:name]
  assert_equal device['visibility'],  result[:visibility]
  assert_equal device['description'], result[:description]
end

assert 'M2X::Client#distribution' do
  subject = M2X::Client.new(TEST_API_KEY)
  result = { id:'a2852df27102179429b3a02641594044',
             name:'test distribution', visibility:'public', description:'foo' }

  distribution = MockSocket.mock!(
    [:get, "/v2/distributions/#{result[:id]}"],
    ['200 OK', json:result]
  ) {
    subject.distribution(result[:id])
  }

  assert_true distribution.is_a?(M2X::Client::Distribution)
  assert_equal distribution['id'],          result[:id]
  assert_equal distribution['name'],        result[:name]
  assert_equal distribution['visibility'],  result[:visibility]
  assert_equal distribution['description'], result[:description]
end

assert 'M2X::Client::Device#stream' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Device.new(client,
    "id"=>"a2852df27102179429b3a02641594044", "name"=>"test device")

  name = 'test_stream'
  result = { name: name, type: 'numeric', value: 32,
             unit: { label: 'celsius', symbol: 'C' } }

  stream = MockSocket.mock!(
    [:get, "/v2/devices/#{subject['id']}/streams/#{name}"],
    ['200 OK', json:result]
  ) {
    subject.stream(name)
  }

  assert_true stream.is_a?(M2X::Client::Stream)
  assert_equal stream['name'],           result[:name]
  assert_equal stream['type'],           result[:type]
  assert_equal stream['value'],          result[:value]
  assert_equal stream['unit']['label'],  result[:unit][:label]
  assert_equal stream['unit']['symbol'], result[:unit][:symbol]
end

assert 'M2X::Client::Device#update_location' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Device.new(client,
    "id"=>"a2852df27102179429b3a02641594044", "name"=>"test device")

  params = { name:'Storage Room',
             latitude:-37.9788423562422, longitude:-57.5478776916862,
             timestamp: "2014-09-10T19:15:00.756Z", elevation: 5 }
  result = { status:'accepted' }

  res = MockSocket.mock!(
    [:put, "/v2/devices/#{subject['id']}/location", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.update_location(params)
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))
end

assert 'M2X::Client::Device#update_stream' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Device.new(client,
    "id"=>"a2852df27102179429b3a02641594044", "name"=>"test device")

  name = 'test_stream'
  params = { unit: { label:"celsius", symbol:"C" }, type:"numeric" }

  res = MockSocket.mock!(
    [:put, "/v2/devices/#{subject['id']}/streams/#{name}", json:params],
    ['204 No Content']
  ) {
    subject.update_stream(name, params)
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   204
  assert_equal res.success?, true
end

assert 'M2X::Client::Device#post_update' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Device.new(client,
    "id"=>"a2852df27102179429b3a02641594044", "name"=>"test device")

  params = {
    timestamp:'2014-09-09T19:15:00.981Z',
    values: {
      temperature: 32,
      humidity: 88
    }
  }
  result = { status:'accepted' }

  res = MockSocket.mock!(
    [:post, "/v2/devices/#{subject['id']}/update", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.post_update(params)
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))
end

assert 'M2X::Client::Device#post_updates' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Device.new(client,
    "id"=>"a2852df27102179429b3a02641594044", "name"=>"test device")

  params = { values: {
    temperature: [
      { timestamp:'2014-09-09T19:15:00.981Z', value:32 },
      { timestamp:'2014-09-09T20:15:00.124Z', value:30 },
      { timestamp:'2014-09-09T21:15:00.124Z', value:15 }
    ],
    humidity: [
      { timestamp:'2014-09-09T19:15:00.874Z', value:88 },
      { timestamp:'2014-09-09T20:15:00.752Z', value:60 },
      { timestamp:'2014-09-09T21:15:00.752Z', value:75 }
    ],
  }}
  result = { status:'accepted' }

  res = MockSocket.mock!(
    [:post, "/v2/devices/#{subject['id']}/updates", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.post_updates(params)
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))
end

assert 'M2X::Client::Distribution#create_device' do
  client = M2X::Client.new(TEST_API_KEY)
  subject = M2X::Client::Distribution.new(client,
    "id"=>"fefd6d0f4bd8aa25479a8ea4760319a5")
  params = { serial:'ABC12345' }
  result = params.merge(id:'a2852df27102179429b3a02641594044',
    name:"test device", visibility:"public", description:"foo")

  device = MockSocket.mock!(
    [:post, "/v2/distributions/#{subject['id']}/devices", json:params],
    ['201 Created', json:result]
  ) {
    device = subject.add_device(params[:serial])
  }

  assert_true device.is_a?(M2X::Client::Device)
  assert_equal device['id'],          result[:id]
  assert_equal device['serial'],      result[:serial]
  assert_equal device['name'],        result[:name]
  assert_equal device['visibility'],  result[:visibility]
  assert_equal device['description'], result[:description]
end

assert 'M2X::Client::Stream#update_value' do
  client = M2X::Client.new(TEST_API_KEY)
  device = M2X::Client::Device.new(client, "id"=>"a2852df27102179429b3a02641594044")
  subject = M2X::Client::Stream.new(client, device, "name"=>"temperature")

  params = { value:100, timestamp:'2014-10-01T12:00:00Z' }
  result = { status:'accepted' }

  res = MockSocket.mock!(
    [:put, "/v2/devices/#{device['id']}/streams/#{subject['name']}/value", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.update_value(params[:value], params[:timestamp])
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))

  params.delete(:timestamp)
  res = MockSocket.mock!(
    [:put, "/v2/devices/#{device['id']}/streams/#{subject['name']}/value", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.update_value(params[:value]) # without timestamp
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))
end

assert 'M2X::Client::Stream#post_values' do
  client = M2X::Client.new(TEST_API_KEY)
  device = M2X::Client::Device.new(client, "id"=>"a2852df27102179429b3a02641594044")
  subject = M2X::Client::Stream.new(client, device, "name"=>"temperature")

  params = { values:[
    { value:32, timestamp:'2014-09-09T19:15:00.624Z' },
    { value:30, timestamp:'2014-09-09T20:15:00.522Z' },
    { value:15, timestamp:'2014-09-09T21:15:00.522Z' },
  ]}
  result = { status:'accepted' }

  res = MockSocket.mock!(
    [:post, "/v2/devices/#{device['id']}/streams/#{subject['name']}/values", json:params],
    ['202 Accepted', json:result]
  ) {
    subject.post_values(params[:values])
  }

  assert_true res.is_a?(M2X::Client::Response)
  assert_equal res.status,   202
  assert_equal res.success?, true
  assert_equal res.json,     JSON.parse(JSON.generate(result))
end
