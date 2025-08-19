# Toggle-Steam-Offline.ps1
A minimal PowerShell script that toggles Windows Firewall rules to quickly block or allow Steam network access.

# Usage

- If Steam is installed in a different directory, edit the `$steamExe` variable near the top of the script (e.g., change `C:\Program Files (x86)\Steam\steam.exe` to your actual path).
- Launch the script normally or as Administrator. If started without elevation, it will relaunch itself with elevated privileges.
- Choose:
  - `D` — create firewall rules to block Steam.
  - `E` — remove the rules to re-enable network access.
  - `Q` — quit.
