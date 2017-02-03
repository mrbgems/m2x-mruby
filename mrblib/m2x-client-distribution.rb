module M2X; end
class M2X::Client; end

# Wrapper for the AT&T M2X Devices API.
#
# https://m2x.att.com/developer/documentation/v2/distribution
class M2X::Client::Distribution < M2X::Client::Resource
  # The API path of the distribution.
  def path
    @path ||= "/distributions/#{HTTP::URL.encode(@attributes["id"])}"
  end

  # Add a new device to an existing distribution
  #
  # Accepts a `serial` parameter, that must be a unique identifier
  # within this distribution.
  #
  # https://m2x.att.com/developer/documentation/v2/distribution#Add-Device-to-an-existing-Distribution
  def add_device(serial)
    res = @client.post("#{path}/devices", nil, { serial: serial }, "Content-Type" => "application/json")
    Device.new(@client, res.json) if res.success?
  end

  # Read an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/distribution#Read-Distribution-Metadata
  def read_metadata
    @client.get(metadata_path)
  end

  # Read an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/distribution#Read-Distribution-Metadata-Field
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Update an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Update an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata-Field
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  def metadata_path
    "#{path}/metadata"
  end
end
