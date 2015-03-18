module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for the AT&T M2X Devices API.
#
# https://m2x.att.com/developer/documentation/v2/device
class M2X::Client::Device < M2X::Client::Resource
  # The device's unique id.
  def id
    @id ||= @attributes["id"]
  end

  # The API path of the device.
  def path
    @path ||= "/devices/#{HTTP::URL.encode(id)}"
  end

  # Create a Stream object to access the device's stream with the given name.
  def stream(name)
    res = @client.get("#{path}/streams/#{HTTP::URL.encode(name)}")
    Stream.new(@client, self, res.json) if res.success?
  end

  # Update the current location of the specified device.
  #
  # https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location
  def update_location(params)
    @client.put("#{path}/location", nil, params, "Content-Type" => "application/json")
  end

  # Update a data stream associated with the Device
  # (if a stream with this name does not exist it gets created).
  #
  # https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream
  def update_stream(name, params={})
    stream = Stream.new(@client, self, {"name" => name})
    stream.update!(params)
  end
  alias_method :create_stream, :update_stream

  # Post Device Updates (Multiple Values to Multiple Streams)
  #
  # This method allows posting multiple values to multiple streams
  # belonging to a device and optionally, the device location.
  #
  # All the streams should be created before posting values using this method.
  #
  # The `values` parameter contains an object with one attribute per each stream to be updated.
  # The value of each one of these attributes is an array of timestamped values.
  #
  #      {
  #         temperature: [
  #                        { "timestamp": <Time in ISO8601>, "value": x },
  #                        { "timestamp": <Time in ISO8601>, "value": y },
  #                      ],
  #         humidity:    [
  #                        { "timestamp": <Time in ISO8601>, "value": x },
  #                        { "timestamp": <Time in ISO8601>, "value": y },
  #                      ]
  #
  #      }
  #
  # The optional location attribute can contain location information that will
  # be used to update the current location of the specified device
  #
  # https://staging.m2x.sl.attcompute.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-
  def post_updates(params)
    @client.post("#{path}/updates", nil, params, "Content-Type" => "application/json")
  end
end
