module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for the AT&T M2X Devices API.
#
# https://m2x.att.com/developer/documentation/v2/device
class M2X::Client::Device < M2X::Client::Resource
  # The API path of the device.
  def path
    @path ||= "/devices/#{HTTP::URL.encode(@attributes["id"])}"
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

  # Post Device Update (Single Values to Multiple Streams)
  #
  # https://staging.m2x.sl.attcompute.com/developer/documentation/v2/device#Post-Device-Update--Single-Values-to-Multiple-Streams-
  def post_update(params)
    @client.post("#{path}/update", nil, params, "Content-Type" => "application/json")
  end

  # Post Device Updates (Multiple Values to Multiple Streams)
  #
  # https://staging.m2x.sl.attcompute.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-
  def post_updates(params)
    @client.post("#{path}/updates", nil, params, "Content-Type" => "application/json")
  end

  # Read an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata
  def read_metadata
    @client.get(metadata_path)
  end

  # Read an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata-Field
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Update an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Update an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata-Field
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  def metadata_path
    "#{path}/metadata"
  end
end
