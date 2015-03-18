module M2X; end
class M2X::Client; end

# Wrapper for the AT&T M2X Devices API.
#
# https://m2x.att.com/developer/documentation/v2/distribution
class M2X::Client::Distribution < M2X::Client::Resource
  # The distribution's unique id.
  def id
    @id ||= @attributes["id"]
  end

  # The API path of the distribution.
  def path
    @path ||= "/distributions/#{HTTP::URL.encode(id)}"
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
end
