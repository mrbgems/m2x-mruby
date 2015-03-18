module M2X; end
class M2X::Client; end

# Wrapper for the AT&T M2X Device Streams API.
#
# https://m2x.att.com/developer/documentation/v2/device
class M2X::Client::Stream < M2X::Client::Resource
  def initialize(client, device, attributes)
    @client     = client
    @device     = device
    @attributes = attributes
  end

  # The name of the stream.
  def name
    @name ||= @attributes["name"]
  end

  # The API path of the stream.
  def path
    puts HTTP::URL.encode(name).inspect
    puts @device.path.inspect
    @path ||= "#{@device.path}/streams/#{HTTP::URL.encode(name)}"
  end

  # Update the current value of the stream. The timestamp is optional.
  # If no timestamp is given, the current server time will be used.
  #
  # https://m2x.att.com/developer/documentation/v2/device#Update-Data-Stream-Value
  def update_value(value, timestamp=nil)
    params = { value: value }
    params[:timestamp] = timestamp if timestamp
    @client.put("#{path}/value", nil, params, "Content-Type" => "application/json")
  end

  # Post values to the stream, given an array with the following format:
  #
  #     [
  #       { "timestamp": <Time in ISO8601>, "value": x },
  #       { "timestamp": <Time in ISO8601>, "value": y },
  #       [ ... ]
  #     ]
  #
  # https://m2x.att.com/developer/documentation/v2/device#Post-Data-Stream-Values
  def post_values(value, timestamp=nil)
    params = { values: values }
    @client.post("#{path}/values", nil, params, "Content-Type" => "application/json")
  end
end
