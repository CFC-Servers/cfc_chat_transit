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
ChatTransit.BroadcastMessage = function(author, authorColor, message)
  if not (shouldTransmit:GetBool()) then
    return 
  end
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
