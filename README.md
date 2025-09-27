[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

EUP Menu for FiveM
Transform your server's clothing system with EUP Menu!
A sleek, user-friendly menu system for FiveM that lets players create, save, and apply custom EUP (Emergency Uniform Pack) uniforms with ease. Built with RageUI and ox_lib, this resource offers a modern interface for organizing uniforms into menus and submenus, with persistent storage in a server-side outfits.json file. Perfect for roleplay servers looking to streamline uniform management for police, EMS, or any custom outfits!

✨ Features

Dynamic Menu Creation: Create custom menus (e.g., "Police") and submenus (e.g., "Patrol") to organize uniforms.
Uniform Saving: Save your current ped's clothing as a named uniform to any submenu with a simple text input (e.g., "Police/Patrol").
Persistent Storage: Uniforms, menus, and submenus are saved to outfits.json and persist across server restarts.
Intuitive Navigation: Use Backspace to navigate back through menus (subsubmenu → submenu → main menu) and ESC to exit. Reopen anytime with /eup.
Error Handling: Clear notifications for invalid inputs or save failures, with detailed client/server logs for debugging.
Lightweight & Compatible: Built with RageUI and ox_lib for a smooth, modern UI that integrates seamlessly into your server.


🚀 How to Use

Open the Menu:

Run /eup in-game to open the EUP Menu.


Create Menus and Submenus:

Select Create a Menu and enter a name (e.g., "Police").
Navigate to a menu and select Create Sub Menu to add submenus (e.g., "Patrol").


Save Uniforms:

Select Add Uniform in the main menu.
Enter a uniform name (e.g., "Test Uni") and a submenu path (e.g., "Police/Patrol" or just "Patrol" if unique).
Your current ped's clothing is saved to the specified submenu.


Apply Uniforms:

Navigate to a menu (e.g., "Police") and submenu (e.g., "Patrol").
Select a saved uniform (e.g., "Test Uni") to apply it instantly.


Navigation:

Press Backspace to go back to the parent menu or exit from the main menu.
Press ESC to close the menu completely.
Reopen with /eup at any time.




🛠️ Installation

Download the Resource:

Clone or download this repository to your server's resources folder.


Install Dependencies:

Ensure RageUI and ox_lib are installed in your resources folder.


Add to Server Config:

Add ensure EUP-Menu to your server.cfg after RageUI and ox_lib.


Set Permissions:

Ensure the server has read/write permissions for the EUP-Menu folder:

Linux: chmod -R 755 /path/to/fivem/resources/EUP-Menu
Windows: Run the server as administrator.




Restart the Server:

Run refresh and restart EUP-Menu in the server console, or restart the server.


Optional: Create an empty outfits.json file in the EUP-Menu folder with {} if it doesn’t exist.


📋 Requirements

FiveM Server (Cerulean FX version or later)
RageUI (for menu rendering)
ox_lib (for notifications and input dialogs)


🐛 Debugging

Client Logs: Press F8 in-game to view detailed logs (e.g., menu navigation, uniform saving).
Server Logs: Check the server console for file save/load messages.
Common Issues:

Menu won’t open: Ensure RageUI and ox_lib are running (ensure RageUI and ensure ox_lib in server.cfg).
Uniforms not saving: Verify folder permissions and check server logs for [EUP_Menu] ERROR: Failed to save outfits.json.
Invalid submenu path: Ensure the entered path (e.g., "Police/Patrol") matches existing menus/submenus exactly.

🌟 Contributing
Found a bug or have a feature idea? Open an issue or submit a pull request! We welcome contributions to make EUP Menu even better.

Ready to level up your server's uniform system? Install EUP Menu and let your players create their perfect outfits! 🚓👨‍🚒