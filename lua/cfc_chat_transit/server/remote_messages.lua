local IsValid
IsValid = _G.IsValid
util.AddNetworkString("CFC_ChatTransit_RemoteMessagePreference")
util.AddNetworkString("CFC_ChatTransit_RemoteMessageReceive")
local recipients = RecipientFilter()
local adminRecipients = RecipientFilter()
local shouldTransmit = CreateConVar("cfc_chat_transit_should_transmit_remote", 1, FCVAR_ARCHIVE, "Should transmit remote messages", 0, 1)
local adminOnly = CreateConVar("cfc_chat_transit_transmit_admin_only", 1, FCVAR_ARCHIVE, "Should only transmit to Admins?", 0, 1)
net.Receive("CFC_ChatTransit_RemoteMessagePreference", function(_, ply)
  local shouldReceive = net.ReadBool()
  if shouldReceive then
    recipients:AddPlayer(ply)
    if adminOnly:GetBool() and ply:IsAdmin() then
      adminRecipients:AddPlayer(ply)
    end
    return 
  end
  recipients:RemovePlayer(ply)
  return adminRecipients:RemovePlayer(ply)
end)
local broadcastMessage
broadcastMessage = function(ply, cmd, args, argStr)
  if not (shouldTransmit:GetBool()) then
    return 
  end
  if IsValid(ply) then
    return 
  end
  local author = rawget(args, 1)
  local authorColor = rawget(args, 2)
  local message = rawget(args, 3)
  if not (author) then
    return 
  end
  if not (authorColor) then
    return 
  end
  if not (message) then
    return 
  end
  authorColor = string.ToColor(authorColor)
  local sendingTo = adminOnly:GetBool() and adminRecipients or recipients
  net.Start("CFC_ChatTransit_RemoteMessageReceive")
  net.WriteString(author)
  net.WriteColor(authorColor)
  net.WriteString(message)
  return net.Send(sendingTo)
end
return concommand.Add("chat_transit", broadcastMessage)
