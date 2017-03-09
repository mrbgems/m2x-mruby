module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

# Wrapper for {https://m2x.att.com/developer/documentation/v2/commands M2X Commands} API
class M2X::Client::Commands < M2X::Client::Resource

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#List-Sent-Commands List Sent Commands} endpoint.
  # Retrieve the list of recent commands sent by the current user
  # (as given by the API key).
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return (Array) List of {Commands} objects
  def list_commands(params)
    @client.get("/commands", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#Send-Command Send Command} endpoint.
  # Send a command with the given name to the given target devices.
  # The name should be a custom string defined by the user and understood by
  # the device.
  #
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return {Commands} The Command that was just sent.
  def send_command(params)
    @client.post("/commands", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#View-Command-Details View Command Details} endpoint.
  # Get details of a sent command including the delivery information for all
  # devices that were targeted by the command at the time it was sent.
  #
  # @param (String) command_id Command ID to be viewed
  # @return {Commands} The Command Retrieved.
  def view_command(command_id)
    @client.get("/commands/#{command_id}")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#Device-s-List-of-Received-Commands Device's List of Recieved Commands} endpoint.
  #
  # @param (String) deviceId The device of which the commands need to be retrieved.
  # @param params Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
  # @return (Array) List of {Commands} objects.
  def receivedCommandsListByDevice(deviceId, params)
    @client.get("/devices/#{deviceId}/commands", nil, params, "Content-Type" => "application/json")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#Device-s-View-of-Command-Details Device's View of Command Details} endpoint.
  # Get details of a received command including the delivery information for this device.
  #
  # @param (String) deviceId The device of which the command needs to be retrieved.
  # @param (String) commandId Command ID to view
  # @return {Command} object retrieved
  def viewDeviceCommandDetails(deviceId, commandId)
    @client.get("/devices/#{deviceId}/commands/#{commandId}")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Processed Process Command} endpoint.
  #
  # @param (String) deviceId Device ID The device of which the command needs to be retrieved.
  # @param (String) commandId Command ID to process
  # @return {Response} The API response, see M2X API docs for details
  def updateCommandStatusAsProcessed(deviceId, commandId)
    @client.post("/devices/#{deviceId}/commands/#{commandId}/process")
  end

  # Method for {https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Rejected Reject Command} endpoint.
  #
  # @param (String) deviceId Device ID The device of which the command needs to be retrieved.
  # @param (String) commandId Command ID to process
  # @return {Response} The API response, see M2X API docs for details
  def updateCommandStatusAsRejected(deviceId, commandId)
    @client.post("/devices/#{deviceId}/commands/#{commandId}/reject")
  end
end
