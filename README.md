# cfc_chat_transit
Paving paths and establishing tunnels

## Convars

### Server
- **`cfc_avatar_service_address`**
  - The domain (`avatar_api.mydomain.com`) of the Avatar Service API

- **`cfc_avatar_service_image_address`**
  - The domain (`avatars.mydomain.com`) that the Avatar images are actually served from

- **`cfc_relay_host`**
  - The domain (`relay.mydomain.com`) of the `discord_relay` service

- `cfc_realm`
  - The Realm (`cfc3` / `cfcttt` / `darkrp`) of the server that is running the addon

- **`cfc_chat_transit_should_transmit_remote`**
  - Whether or not to send Discord messages to players

- **`cfc_chat_transit_transmit_admin_only`**
  - Whether or not to send Discord messages to only Admin+


### Client
- **`cfc_chat_transit_remote_messages`**
  - Whether or not Discord messages should appear in Chat

### Hooks
- **`CFC_ChatTransit_GetPlayerColor`**
  - Takes a Player. Return a Color to override the color that outlines their avatar in Discord
