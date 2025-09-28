[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

EUP Menu for FiveM
Transform your server's clothing system with EUP Menu!A sleek, dual-menu system for FiveM that lets players apply custom EUP (Emergency Uniform Pack) uniforms and admins manage them effortlessly. Built with RageUI and ox_lib, this resource offers a modern interface for organizing uniforms into menus and submenus, with persistent storage in a server-side outfits.json file. Perfect for roleplay servers looking to streamline uniform management for police, EMS, or any custom outfits!

✨ Features

Dual Menus:
/eup: User-friendly menu for all players to apply saved uniforms.
/eupadmin: Admin-only menu to create menus, submenus, and save uniforms (requires eup.admin permission).


Dynamic Management: Admins can create menus (e.g., "Police") and submenus (e.g., "Patrol") and save uniforms to specific submenus using a simple path input (e.g., "Police/Patrol").
Uniform Application: Players can browse menus/submenus and apply uniforms instantly.
Persistent Storage: Uniforms, menus, and submenus are saved to outfits.json and persist across server restarts.
Intuitive Navigation: Use Backspace to navigate back (subsubmenu → submenu → main/admin menu) and ESC to exit. Reopen with /eup or /eupadmin.
Robust Error Handling: Clear notifications for invalid inputs or save failures, with detailed client/server logs for debugging.
Lightweight & Compatible: Built with RageUI and ox_lib for a smooth, modern UI.


🚀 How to Use
For Players (/eup)

Run /eup to open the main menu.
Browse menus (e.g., "Police") and submenus (e.g., "Patrol").
Select a uniform (e.g., "Test Uni") to apply it instantly.
Press Backspace to go back to the parent menu or ESC to close.

For Admins (/eupadmin)

Run /eupadmin (requires eup.admin permission).
Create a Menu: Enter a name (e.g., "Fire") to create a new menu.
Create Sub Menu: Select an existing menu and add a submenu (e.g., "Station" under "Fire").
Add Uniform: Save your current ped's clothing to a submenu by entering a uniform name and path (e.g., "Fire/Station").
Navigate and close as with the main menu.


🛠️ Installation

Download the Resource:

Clone or download this repository to your server's resources folder.


Install Dependencies:

Ensure RageUI and ox_lib are installed in your resources folder.


Add to Server Config:

Add to server.cfg:ensure RageUI
ensure ox_lib
ensure EUP-Menu




Set Permissions:

Add ACE permission for admins:add_ace group.admin eup.admin allow



Create outfits.json:

Create an empty outfits.json file in the EUP-Menu folder with {} if it doesn’t exist.


Restart the Server:

Run refresh and restart EUP-Menu in the server console, or restart the server.




📋 Requirements

FiveM Server (Cerulean FX version or later)
RageUI (for menu rendering)
ox_lib (for notifications and input dialogs)


🐛 Debugging

Client Logs: Press F8 in-game to view logs (e.g., menu navigation, uniform saving, permission checks).
Server Logs: Check the server console for file save/load and permission messages.
Common Issues:
Menu won’t open: Ensure RageUI and ox_lib are running.
/eupadmin denied: Verify eup.admin permission in server.cfg.
Uniforms not saving: Check folder permissions and server logs for [EUP_Menu] ERROR: Failed to save outfits.json.
Invalid submenu path: Ensure the path (e.g., "Police/Patrol") matches existing menus/submenus exactly.




📝 Example outfits.json
{
    "Police": {
        "submenus": {
            "Patrol": {
                "uniforms": {
                    "Test Uni": {
                        "hat": 151,
                        "shirt": 309,
                        "pants": 213,
                        ...
                    }
                }
            }
        }
    }
}


📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

🌟 Contributing
Found a bug or have a feature idea? Open an issue or submit a pull request! We welcome contributions to make EUP Menu even better.

Ready to level up your server's uniform system? Install EUP Menu and let players and admins manage outfits with ease! 🚓👨‍🚒