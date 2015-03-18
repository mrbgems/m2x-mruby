module M2X; end
class M2X::Client; end

# Wrapper for M2X::Client resources
class M2X::Client::Resource
  def initialize(client, attributes)
    @client     = client
    @attributes = attributes
  end

  # Return a specific attribute of the resource, referenced by the given key.
  def [](key)
    @attributes[key]
  end

  # Retrieve and return the resource's current attributes.
  def view
    res = @client.get(path)
    @attributes = res.json if res.success?
  end

  # Update an existing resource's attributes.
  def update!(params)
    res = @client.put(path, nil, params, "Content-Type" => "application/json")
    @attributes = res.json if res.status == 201
    res
  end

  # Delete the resource.
  def delete!
    @client.delete(path)
  end

  def inspect
    "#<#{self.class.name}: #{@attributes.inspect}>"
  end

  # The API path of the resource, to be implemented by the subclass.
  def path
    raise NotImplementedError
  end
end
