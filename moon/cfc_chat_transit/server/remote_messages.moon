import AddNetworkString from util
import Start, Receive, ReadBool, WriteColor, WriteString, Send from net
import ToColor from string

AddNetworkString "CFC_ChatTransit_RemoteMessagePreference"
AddNetworkString "CFC_ChatTransit_RemoteMessageReceive"

IsValid = IsValid
recipients = RecipientFilter!

shouldTransmit = CreateConVar "cfc_chat_transit_should_transmit_remote", 0, FCVAR_ARCHIVE, "Should transmit remote messages", 0, 1

Receive "CFC_ChatTransit_RemoteMessagePreference", (_, ply) ->
    shouldReceive = ReadBool!

    modify = shouldReceive and recipients.AddPlayer or recipients.RemovePlayer

    modify recipients, ply

broadcastMessage = (ply, cmd, args, argStr) ->
    return unless shouldTransmit\GetBool!

    return if IsValid ply

    author = rawget args, 1
    authorColor = rawget args, 2
    message = rawget args, 3

    return unless author
    return unless authorColor
    return unless message

    authorColor = ToColor authorColor

    Start "CFC_ChatTransit_RemoteMessageReceive"
    WriteString author
    WriteColor authorColor
    WriteString message
    Send recipients

concommand.Add "chat_transit", broadcastMessage
