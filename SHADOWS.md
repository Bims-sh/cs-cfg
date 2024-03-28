### PowerShell Script (Windows)

#### How to Use the PowerShell Script

You can execute the PowerShell script directly from the command line without downloading it. Follow the steps below:

1. Open PowerShell.
2. Copy and paste the following command to execute the script:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Bims-sh/cs-cfg/main/enable-shadows.ps1" -OutFile "enable-shadows.ps1"; .\script.ps1 -filePath "C:\Program Files (x86)\Steam\userdata\XXX\730\local\cfg\cs2_video.txt"
```

> **Note**: Replace `C:\\Program Files (x86)\\Steam\\userdata\\XXX\\730\\local\\cfg\\cs2_video.txt` with your video config path.

---

### Shell Script (Linux)

#### How to Use the Shell Script

You can execute the shell script directly from the command line without downloading it. Follow the steps below:

1. Open a terminal window.
2. Copy and paste the following commands to execute the script:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/Bims-sh/cs-cfg/main/enable-shadows.sh)" "~/home/.local/share/Steam/userdata/XXX/730/local/cfg/cs2_video.txt"
```

> **Note**: Replace `~/home/.local/share/Steam/userdata/XXX/730/local/cfg/cs2_video.txt` with your video config path.