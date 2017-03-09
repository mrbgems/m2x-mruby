module M2X; end
class M2X::Client; end

# Wrapper for {https://m2x.att.com/developer/documentation/v2/device M2X Data Streams} API.
class M2X::Client::Stream < M2X::Client::Resource
  def initialize(client, device, attributes)
    @client     = client
    @device     = device
    @attributes = attributes
  end

  # The API path of the stream.
  def path
    @path ||= "#{@device.path}/streams/#{HTTP::URL.encode(@attributes["name"])}"
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Update-Data-Stream-Value Update Data Stream Value} endpoint.
  # The timestamp is optional. If omitted, the current server time will be used.
  #
  # @param (String) value Value to be updated
  # @param (String) timestamp Current Timestamp
  # @return void
  def update_value(value, timestamp=nil)
    params = { value: value }
    params[:timestamp] = timestamp if timestamp
    @client.put("#{path}/value", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Post-Data-Stream-Values Post Data Stream Values} endpoint.
  # Post multiple values to the stream
  # The `values` parameter is an array with the following format:
  #     [
  #       { "timestamp": <Time in ISO8601>, "value": x },
  #       { "timestamp": <Time in ISO8601>, "value": y },
  #       [ ... ]
  #     ]
  #
  # @param values The values being posted, formatted according to the API docs
  # @return {Response} The API response, see M2X API docs for details
  def post_values(values)
    params = { values: values }
    @client.post("#{path}/values", nil, params, "Content-Type" => "application/json")
  end
end
