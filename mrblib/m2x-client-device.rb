module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for {https://m2x.att.com/developer/documentation/v2/device M2X Device} API
class M2X::Client::Device < M2X::Client::Resource
  # The API path of the device.
  def path
    @path ||= "/devices/#{HTTP::URL.encode(@attributes["id"])}"
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#View-Data-Stream View Data Stream} endpoint.
  #
  # @param (String) name name of the stream to be fetched
  # @return {Stream} The matching stream
  def stream(name)
    res = @client.get("#{path}/streams/#{HTTP::URL.encode(name)}")
    Stream.new(@client, self, res.json) if res.success?
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location Update Device Location} endpoint.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} The API response, see M2X API docs for details.
  def update_location(params)
    @client.put("#{path}/location", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream Create Update Data Stream} endpoint.
  # (if a stream with this name does not exist it gets created).
  #
  # @param (String) name Name of the stream to be updated
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Stream} The Stream being updated
  def update_stream(name, params={})
    stream = Stream.new(@client, self, {"name" => name})
    stream.update!(params)
  end
  alias_method :create_stream, :update_stream

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Post-Device-Update--Single-Values-to-Multiple-Streams- Post Device Update (Single Value to Multiple Streams)} endpoint.
  # All the streams should be created before posting values using this method.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} the API response, see M2X API docs for details
  def post_update(params)
    @client.post("#{path}/update", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams- Post Device Updates (Multiple Values to Multiple Streams)} endpoint.
  # All the streams should be created before posting values using this method.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} the API response, see M2X API docs for details
  def post_updates(params)
    @client.post("#{path}/updates", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata Read Device Metadata} endpoint.
  #
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata
    @client.get(metadata_path)
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata-Field Read Device Metadata Field} endpoint.
  #
  # @param (String) field_name The metada field to be read
  # @return {Response} The API response, see M2X API docs for details
  def read_metadata_field(field_name)
    @client.get("#{metadata_path}/#{field_name}")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata Update Device Metadata} endpoint.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata(params)
    @client.put(metadata_path, nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata-Field Update Device Metadata Field} endpoint.
  #
  # @param (String) field_name The metadata field to be updated
  # @param (String) value The value to be updated
  # @return {Response} The API response, see M2X API docs for details
  def update_metadata_field(field_name, value)
    @client.put("#{metadata_path}/#{field_name}", nil, { value: value }, "Content-Type" => "application/json")
  end

  # The API path of the device's metadata.
  def metadata_path
    "#{path}/metadata"
  end
end
