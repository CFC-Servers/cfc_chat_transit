require "steamlookup"

include "cfc_chat_transit/server/init.lua"
include "cfc_chat_transit/server/remote_messages.lua"

AddCSLuaFile "cfc_chat_transit/client/init.lua"
AddCSLuaFile "cfc_chat_transit/client/menu.lua"
AddCSLuaFile "cfc_chat_transit/client/receive_remote_message.lua"
