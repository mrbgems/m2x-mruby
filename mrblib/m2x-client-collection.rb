module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for the AT&T M2X Devices API.
#
# https://m2x.att.com/developer/documentation/v2/collections
class M2X::Client::Collection < M2X::Client::Resource
  # The API path of the collection.
  def path
    @path ||= "/collections/#{HTTP::URL.encode(@attributes["id"])}"
  end

  # Read an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata
  def read_metadata
    @client.get(metadata_path)
  end

  # Read an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata-Field
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Update an object's metadata
  #
  # https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Update an object's metadata field
  #
  # https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata-Field
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  def metadata_path
    "#{path}/metadata"
  end
end
