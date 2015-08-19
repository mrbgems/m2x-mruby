module M2X; end

# Interface for connecting with the AT&T M2X API.
#
# Create a Client and use it to create or access Resource objects or
# use the Client to directly access any M2X API endpoint using REST methods:
#
#     m2x = M2X::Client.new("<YOUR-API-KEY>")
#     m2x.get("/some_path")
#
class M2X::Client
  VERSION = "0.1.0"

  DEFAULT_API_BASE    = "http://api-m2x.att.com"
  DEFAULT_API_VERSION = "v2"

  USER_AGENT = "M2X-MRuby/#{M2X::Client::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"

  attr_accessor :api_key
  attr_accessor :api_base
  attr_accessor :api_version
  attr_reader   :last_response

  def initialize(api_key=nil, api_base=nil, api_version=nil)
    @api_key     = api_key
    @api_base    = api_base    || DEFAULT_API_BASE
    @api_version = api_version || DEFAULT_API_VERSION
  end

  # Creates a new device on M2X with the specified parameters.
  #
  # https://m2x.att.com/developer/documentation/v2/device#Create-Device
  def create_device(params)
    res = post("/devices", nil, params, "Content-Type" => "application/json")
    Device.new(self, res.json) if res.success?
  end

  # Fetch the existing device that has the given id.
  def device(id)
    res = get("/devices/#{id}")
    Device.new(self, res.json) if res.success?
  end

  # Fetch the existing distribution that has the given id.
  def distribution(id)
    res = get("/distributions/#{id}")
    Distribution.new(self, res.json) if res.success?
  end

  # Define REST methods for accessing the M2X API directly.
  [:get, :post, :put, :delete, :head, :options, :patch].each do |verb|
    define_method verb do |path, qs=nil, params=nil, headers=nil|
      request(verb, path, qs, params, headers)
    end
  end

  private

  def request(verb, path, qs=nil, params=nil, headers=nil)
    url = url_from(path)
    raise "SSL is not supported" if url.schema == "https"

    url.query = encode_www_form(qs) unless qs.nil? || qs.empty?

    headers = default_headers.merge(headers || {})

    body = if params
      headers["Content-Type"] ||= "application/x-www-form-urlencoded"

      case headers["Content-Type"]
      when "application/json" then ::JSON.generate(params)
      when "application/x-www-form-urlencoded" then encode_www_form(params)
      else
        raise ArgumentError, "Unrecognized Content-Type `#{headers["Content-Type"]}`"
      end
    end
    headers["Content-Length"] = body.bytesize if body

    path = url.path
    path << "?#{url.query}" if url.query

    socket = new_socket(url.host, url.port || 80)
    socket.write(encoded_request(verb.to_s.upcase, path, body, headers))

    # TODO: support chunked responses
    @last_response = Response.new(read_response(socket))
  end

  def http_parser
    @http_parser ||= HTTP::Parser.new
  end

  def new_socket(host, port)
    ::TCPSocket.new(host, port)
  end

  def default_headers
    @default_headers ||= { "User-Agent" => USER_AGENT }
    @default_headers["X-M2X-KEY"] = api_key if api_key
    @default_headers
  end

  def url_from(path)
    path = path[1..-1] if path[0] == '/'
    http_parser.parse_url([api_base, api_version, path].join('/'))
  end

  def encode_www_form(params)
    params.map do |key, value|
      "#{HTTP::URL.encode(key.to_s)}=#{HTTP::URL.encode(value.to_s)}"
    end.join('&')
  end

  def encoded_request(method, request_uri, body, headers)
    # Implements RFC 2616 section 5
    http_version = "HTTP/1.1"
    request_line = "#{method} #{request_uri} #{http_version}\r\n"
    header_lines = headers.map { |pair| pair.join(': ') }.join("\r\n")+"\r\n"
    "#{request_line}#{header_lines}\r\n#{body}"
  end

  def read_response(socket)
    text = ""
    content_length = nil
    while true
      line = socket.readline
      break if line.nil?
      text += line
      break if line == "\r\n"
      if line.index("Content-Length: ")
        content_length = line["Content-Length: ".size..-3].to_i
      end
    end
    if content_length
      text += socket.read(content_length)
    end

    http_parser.parse_response(text)
  end
end
