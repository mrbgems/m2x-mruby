# Wrapper for AT&T M2X Commands API
# https://m2x.att.com/developer/documentation/v2/commands
module M2X; end
class M2X::Client; end
class M2X::Client::Resource; end

class M2X::Client::Commands < M2X::Client::Resource

  # List Sent Commands
  #
  # Retrieve the list of recent commands sent by the current user
  # (as given by the API key).
  # 
  # https://m2x.att.com/developer/documentation/v2/commands#List-Sent-Commands
  def list_commands(params)
    @client.get("/commands", nil, params, "Content-Type" => "application/json")
  end

  # Send Command
  #
  # Send a command with the given name to the given target devices.
  # The name should be a custom string defined by the user and understood by
  # the device.
  #
  # https://m2x.att.com/developer/documentation/v2/commands#Send-Command
  def send_command(params)
    @client.post("/commands", nil, params, "Content-Type" => "application/json")
  end

  # View Command Details
  #
  # Get details of a sent command including the delivery information for all
  # devices that were targeted by the command at the time it was sent.
  #
  # https://m2x.att.com/developer/documentation/v2/commands#View-Command-Details
  def view_command(command_id)
    @client.get("/commands/#{command_id}")
  end

  # Device's List of Received Commands
  #
  # Retrieve the list of recent commands sent to the current device.
  # (as given by the API key).
  #
  # https://m2x.att.com/developer/documentation/v2/commands#Device-s-List-of-Received-Commands
  def receivedCommandsListByDevice(deviceId, params)
    @client.get("/devices/#{deviceId}/commands", nil, params, "Content-Type" => "application/json")
  end

  # Device's View of Command Details
  #
  # Get details of a received command including the delivery information for this device
  #
  # https://m2x.att.com/developer/documentation/v2/commands#Device-s-View-of-Command-Details
  def viewDeviceCommandDetails(deviceId, commandId)
    @client.get("/devices/#{deviceId}/commands/#{commandId}")
  end

  # Device Marks a Command as Processed
  #
  # Mark the given command as processed by the device
  #
  # https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Processed
  def updateCommandStatusAsProcessed(deviceId, commandId)
    @client.post("/devices/#{deviceId}/commands/#{commandId}/process")
  end

  # Device Marks a Command as Rejected
  #
  # Mark the given command as rejected by the device
  #
  # https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Rejected
  def updateCommandStatusAsRejected(deviceId, commandId)
    @client.post("/devices/#{deviceId}/commands/#{commandId}/reject")
  end
end
