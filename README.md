# ToDoQuickAdd

A lightweight AutoHotkey script that enables quick task creation in Microsoft To Do. Press CTRL+ALT+T to instantly add tasks from anywhere on your system.

![image](https://github.com/user-attachments/assets/4034d4f3-fb3c-4a7f-8335-a1c376537cc8)   ![image](https://github.com/user-attachments/assets/9ca71694-3e0e-421a-920a-12b9a1887ddd)


## Features

- Optional task descriptions
- Configurable hotkey
- System tray integration
- Clipboard content auto-fill
- Logging (for troubleshooting)

## Prerequisites

- Windows operating system
- Either:
  - Download the compiled .exe file from the releases section of this repository
  - OR Install AutoHotkey v2.0 or later from [https://www.autohotkey.com/](https://www.autohotkey.com/) to run the .ahk script
- Microsoft 365 account with access to Power Automate
- Microsoft To Do

## Installation

### Option 1: Using the Executable
1. Download ToDoQuickAdd.exe from the releases section
2. Place it in your desired location
3. Double-click the .exe to run it

### Option 2: Using the Script (requires AutoHotkey)
1. Install AutoHotkey v2.0 or later from the official website
2. Clone this repository or download the files:
   - ToDoQuickAdd.ahk
   - ToDoQuickAdd.ico (optional)
3. Double-click the .ahk script to run it

### First-Time Setup
On first run, you'll be prompted to enter your Power Automate HTTP trigger URL (see PowerAutomate_Setup.md for details)

## Usage

### Adding Tasks

1. Press `CTRL+ALT+T` anywhere in Windows
2. Dialog box 1/2 will appear on your active monitor asking for the Task Title
   - Your clipboard content will be automatically pre-filled
   - This will be the main task name in Microsoft To Do
3. Dialog box 2/2 will appear asking for an optional Task Description
   - You can leave this empty if no description is needed
   - This will appear in the task details/notes section
4. The task will be created in your Microsoft To Do default tasks list with both pieces of information

### System Tray Options

Right-click the system tray icon to access:
- Change API URL: Update your Power Automate connection
- Change hotkey: Set hotkey to what you find logical
- View log: See log to troubleshoot any errors.
- About: View script information
- Exit: Close the script

## File Structure

```
ToDoQuickAdd/
├── ToDoQuickAdd.ahk        # Main script file
├── ToDoQuickAdd.ico        # Tray icon file (optional)
├── PowerAutomate_Setup.md  # Power Automate setup instructions
├── README.md               # This file
└── ToDoQuickAdd_config.ini # Auto-generated config file
```

## Configuration

The script automatically creates a configuration file (`ToDoQuickAdd_config.ini`) to store your Power Automate URL. You can change this URL at any time through the tray menu.

## Error Handling

The script includes comprehensive error handling for:
- Network issues
- Invalid URLs
- Power Automate connection problems
- Configuration file access

Success and Error messages will be displayed via tray notifications.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Clone your fork
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Microsoft Power Automate team for the HTTP trigger functionality
- AutoHotkey community for multi-monitor support functions
- Pictogrammers for logo. (https://pictogrammers.com/library/mdi/icon/check-bold/)

## Support

If you encounter any issues:
1. Check the Power Automate flow is working correctly
2. Verify your network connection
3. Check the URL in the configuration file
4. Create an issue in the GitHub repository

## Security Note

The Power Automate URL contains authentication information. Keep it private and never share it publicly.

## Version History

- v011
  - Pop up at current screen (same as cursor)
  - Implemented configuration persistence
  - Configurable hotkey
  - Logging

## FAQ

**Q: Why use Power Automate instead of direct API integration?**  
A: Power Automate provides a secure, maintainable way to connect to Microsoft To Do without handling authentication in the script.

**Q: Can I customize the hotkey?**  
A: Yes, click on the change hotkey script in the tray menu.

**Q: Where are my tasks added?**  
A: Tasks are added to your default Tasks list in Microsoft To Do.
