[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

EUP Menu for FiveM
Transform your server's clothing system with EUP Menu!A sleek, dual-menu system for FiveM that lets players apply custom EUP (Emergency Uniform Pack) uniforms and admins manage them effortlessly. Built with RageUI and ox_lib, this resource organizes uniforms into menus and submenus, with persistent storage in outfits.json. Supports ACE and Discord role-based permissions for flexible access control.


<img width="436" height="233" alt="Screenshot 2025-09-28 174007" src="https://github.com/user-attachments/assets/c46ff7ce-0200-4b4f-b31c-e1ec76dd55a0" /> 
<img width="439" height="302" alt="Screenshot 2025-09-28 173949" src="https://github.com/user-attachments/assets/1e5b7409-a726-4000-9923-300713ff1536" />



✨ Features


Dual Menus:
/eup: User menu to apply saved uniforms (permissions: ACE, Discord, or none).
/eupadmin: Admin-only menu to create menus, submenus, and save uniforms.


Flexible Permissions:
Configure up to 4 Discord roles or ACE permissions for /eup and /eupadmin.
/eup can be open to all (none), restricted by ACE, or Discord roles.


Dynamic Management: Admins create menus (e.g., "Police"), submenus (e.g., "Patrol"), and save uniforms to paths (e.g., "Police/Patrol").
Persistent Storage: Uniforms, menus, and submenus saved to outfits.json.
Intuitive Navigation: Backspace to navigate back, ESC to exit.
Robust Error Handling: Notifications for invalid inputs or permissions, with detailed logs.


🚀 How to Use
For Players (/eup)

Run /eup (if permitted).
Browse menus (e.g., "Police") and submenus (e.g., "Patrol").
Select a uniform to apply it.
Press Backspace to go back or ESC to close.

For Admins (/eupadmin)

Run /eupadmin (requires permission).
Create a Menu: Add a new menu (e.g., "Fire").
Create Sub Menu: Add a submenu (e.g., "Station" under "Fire").
Add Uniform: Save ped’s clothing to a submenu path (e.g., "Fire/Station").
Navigate and close as with the main menu.


🛠️ Installation

Download the Resource:

Clone or download to your resources folder.


Install Dependencies:

Ensure RageUI and ox_lib are installed.


Add to Server Config:

Add to server.cfg:ensure RageUI
ensure ox_lib
ensure EUP-Menu




Configure Permissions:

Edit config.lua:
BotToken: Discord bot token (required for Discord permissions).
GuildID: Discord server ID.
AdminPermType: "ace" or "discord" for /eupadmin.
EupPermType: "ace", "discord", or "none" for /eup.
AdminDiscordRoles/EupDiscordRoles: Up to 4 Discord role IDs.
AdminAce/EupAce: ACE permission strings (e.g., eup.admin, eup.user).


Example config.lua:
```lua
Config = {}
Config.BotToken = "YOUR_BOT_TOKEN"
Config.GuildID = "YOUR_GUILD_ID"
Config.AdminPermType = "discord"
Config.AdminAce = "eup.admin"
Config.AdminDiscordRoles = {"ROLE_ID_1", "ROLE_ID_2", "", ""}
Config.EupPermType = "discord"
Config.EupAce = "eup.user"
Config.EupDiscordRoles = {"ROLE_ID_3", "", "", ""}
```


Set Up Discord Bot (for Discord permissions):

Go to Discord Developer Portal.
Create a new application, add a bot.
Under "Bot" settings, enable Server Members Intent.
Copy the bot token to Config.BotToken.
Generate an invite link with bot scope and Guild Members permission.
Add the bot to your server.
Get your server ID: Right-click server, "Copy ID" (enable Developer Mode in Discord settings).
Get role IDs: Right-click roles, "Copy ID".
Add IDs to Config.AdminDiscordRoles and Config.EupDiscordRoles.


Set Up ACE Permissions (if using ACE):
```config
Add to server.cfg:add_ace group.admin eup.admin allow
add_ace group.player eup.user allow
```


Example for a specific player:add_ace identifier.steam:110000123456789 eup.admin allow


Create outfits.json:

Create an empty outfits.json in the EUP-Menu folder with {}.


Restart the Server:

Run refresh and restart EUP-Menu in the server console.




📋 Requirements
```
FiveM Server (Cerulean FX or later)
RageUI (menu rendering)
ox_lib (notifications and dialogs)
Discord Bot (for Discord permissions)
```

🐛 Debugging
```
Client Logs: Press F8 for logs (e.g., menu navigation, permissions).

Look for: [EUP_Menu] Permission granted for eup, [EUP_Menu] Opening main menu.


Server Logs: Check for file save/load or Discord API errors.

Look for: [EUP_Menu] Found Discord ID: <id>, [EUP_Menu] Discord roles retrieved: {...}.


Common Issues:

Menu won’t open:
Ensure RageUI and ox_lib are running (ensure RageUI, ensure ox_lib).
Check client logs for [EUP_Menu] Permission denied for eup.
Verify config.lua is loaded (server log: [EUP_Menu] Config loaded: {...}).


Permission denied:
For Discord: Verify BotToken, GuildID, and role IDs in config.lua.
Ensure bot has Server Members Intent and is in the server.
Check player’s Discord ID in logs ([EUP_Menu] Found Discord ID: <id>).
For ACE: Add permissions in server.cfg (e.g., add_ace group.admin eup.admin allow).


Discord API errors:
[EUP_Menu] ERROR: Discord API request failed, status: 401: Invalid bot token. Regenerate in Discord Developer Portal.
status: 403: Bot lacks permissions. Re-invite with Guild Members scope.
status: 429: Rate limit hit. Wait a few minutes or add a delay in server.lua.


Uniforms not saving: Check folder permissions and [EUP_Menu] ERROR: Failed to save outfits.json.
```

Add a debug command to server.lua:
```lua
RegisterCommand('testdiscord', function(source)
    local discordID = GetDiscordID(source)
    if discordID then
        GetDiscordRoles(discordID, function(roles)
            print('[EUP_Menu] Test Discord roles: ' .. json.encode(roles))
        end)
    else
        print('[EUP_Menu] Test failed: No Discord ID')
    end
end, false)


Run /testdiscord in-game and check server logs.
```

📝 Example outfits.json
```json
{
  "Police": {
    "submenus": {
      "Patrol": {
        "uniforms": {
          "Test Uni": {
            "hat": 151,
            "shirt": 309,
            "pants": 213
          }
        }
      }
    }
  }
}
```


📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

🌟 Contributing
Found a bug or have a feature idea? Open an issue or submit a pull request!


Ready to level up your server’s uniform system? Install EUP Menu and manage outfits with ease! 🚓👨‍🚒




