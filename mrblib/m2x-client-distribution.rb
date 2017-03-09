module M2X; end
class M2X::Client; end

# Wrapper for {https://m2x.att.com/developer/documentation/v2/distribution M2X Distribution} API
class M2X::Client::Distribution < M2X::Client::Resource
  # The API path of the distribution.
  def path
    @path ||= "/distributions/#{HTTP::URL.encode(@attributes["id"])}"
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/distribution#Add-Device-to-an-existing-Distribution Add Device to an existing Distribution} endpoint.
  #
  # @param (String) serial The unique (account-wide) serial for the DistributionDevice being added
  # @return {Device} The newly created DistributionDevice
  def add_device(serial)
    res = @client.post("#{path}/devices", nil, { serial: serial }, "Content-Type" => "application/json")
    Device.new(@client, res.json) if res.success?
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/distribution#Read-Distribution-Metadata Read Distribution Metadata} endpoint.
  #
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata
    @client.get(metadata_path)
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/distribution#Read-Distribution-Metadata-Field Read Distribution Metadata Field} endpoint.
  #
  # @param (String) field_name The metada field to be read
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata Update Distribution Metadata} endpoint.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata-Field Update Distribution Metadata Field} endpoint.
  #
  # @param (String) field_name The metadata field to be updated
  # @param (String) value The value to be updated
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  # The API path of the distribution's metadata.
  def metadata_path
    "#{path}/metadata"
  end
end
