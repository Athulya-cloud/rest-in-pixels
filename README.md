# rest-in-pixels 👻

A ghostly eye care reminder for macOS.

Every 20 minutes, a full-screen overlay takes over your screen with an animated ASCII ghost and a random fun fact — forcing you to rest your eyes.

- **20-20-20 rule** — look at something 20 feet away
- **10-second lockout** — can't dismiss early
- **30fps ASCII animation** — 235 frames
- **Auto-starts on login**, survives reboots

## Install

```bash
git clone https://github.com/Athulya-cloud/rest-in-pixels.git ~/.eyecare
cd ~/.eyecare
swiftc -O -o rest-in-pixels overlay.swift -framework Cocoa
```

Set up auto-run (edit paths in the plist if you cloned elsewhere):

```bash
cp com.eyecare.reminder.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.eyecare.reminder.plist
```

## Usage

```bash
# test it
~/.eyecare/rest-in-pixels

# stop
launchctl unload ~/Library/LaunchAgents/com.eyecare.reminder.plist

# restart
launchctl unload ~/Library/LaunchAgents/com.eyecare.reminder.plist
launchctl load ~/Library/LaunchAgents/com.eyecare.reminder.plist
```

## Requirements

- macOS
- Xcode Command Line Tools (`xcode-select --install`)
