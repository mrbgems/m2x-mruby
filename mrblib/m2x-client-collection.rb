module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for {https://m2x.att.com/developer/documentation/v2/collections M2X Collections} API
class M2X::Client::Collection < M2X::Client::Resource
  # The API path of the collection.
  def path
    @path ||= "/collections/#{HTTP::URL.encode(@attributes["id"])}"
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata Read Collection Metadata} endpoint.
  #
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata
    @client.get(metadata_path)
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata-Field Read Collection Metadata Field} endpoint.
  #
  # @param (String) field_name The metadata field to be read
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata Update Collection Metadata} endpoint.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata Update Collection Metadata} endpoint.
  #
  # @param (String) field_name The field to be updated.
  # @param (String) value The new value.
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  # The API path of the collection's metadata.
  def metadata_path
    "#{path}/metadata"
  end
end
