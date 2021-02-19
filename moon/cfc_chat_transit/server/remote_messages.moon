import AddNetworkString, Decompress from util
import Start, Receive, ReadBool, WriteString, Send from net

AddNetworkString "CFC_ChatTransit_RemoteMessagePreference"
AddNetworkString "CFC_ChatTransit_RemoteMessageReceive"

IsValid = IsValid

recipients = RecipientFilter!

Receive "CFC_ChatTransit_RemoteMessagePreference", (_, ply) ->
    shouldReceive = ReadBool!

    modify = shouldReceive and recipients.AddPlayer or recipients.RemovePlayer

    modify recipients, ply

broadcastMessage = (ply, cmd, args, argStr) ->
    return if IsValid ply

    author = rawget args, 1
    message = rawget args, 2

    return unless author
    return unless message

    message = Decompress(argStr) or message

    Start "CFC_ChatTransit_RemoteMessageReceive"
    WriteString author
    WriteString message
    Send recipients

concommand.Add "chat_transit", broadcastMessage
