<h1 align="center">rest-in-pixels 👻</h1>
<p align="center"><b>Your eyes called. They want a break.</b></p>

<p align="center"><img src="assets/demo.gif" alt="rest-in-pixels demo" width="640"></p>

You've been staring at a screen for hours. Every 20 minutes, a friendly ASCII ghost drifts in, takes over your display and tells you to look away. A random fun fact keeps it fun. Twenty seconds later you're back, with eyes that don't feel like sandpaper.

Free, tiny, and macOS only. No account, no dependencies, no nagging notifications you'll swipe away.

## Why you'll like it

- **You can't ignore it.** A full-screen overlay on every display, not a notification you dismiss without reading
- **Built on the 20-20-20 rule:** every 20 minutes, look at something 20 feet away for 20 seconds
- **Never trapped:** press `s` to skip, or `Esc` to quit instantly
- **Set and forget:** starts automatically when you log in

## Install

You need macOS and the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/Athulya-cloud/rest-in-pixels.git ~/.eyecare
cd ~/.eyecare
swiftc -O -o rest-in-pixels overlay.swift -framework Cocoa
```

Turn on the reminder:

```bash
sed "s|__HOME__|$HOME|g" com.eyecare.reminder.plist > ~/Library/LaunchAgents/com.eyecare.reminder.plist
launchctl load ~/Library/LaunchAgents/com.eyecare.reminder.plist
```

The first break appears right away. Want to preview it without the scheduler? Run `~/.eyecare/rest-in-pixels`.

## Turn it off

Pause the reminders (they stay off until you turn them back on, and across restarts):

```bash
launchctl unload -w ~/Library/LaunchAgents/com.eyecare.reminder.plist
```

Turn them back on:

```bash
launchctl load -w ~/Library/LaunchAgents/com.eyecare.reminder.plist
```

Stuck on the overlay? Press `Esc`.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.eyecare.reminder.plist
rm ~/Library/LaunchAgents/com.eyecare.reminder.plist
rm -rf ~/.eyecare
```

## Customize

| To change | Edit |
|---|---|
| Time between breaks | `StartInterval` in `com.eyecare.reminder.plist` (seconds, default `1200`) |
| Break length | `countdown` in `overlay.swift` (default `20`) |
| Fun facts | `facts.json` |
| Colors and fonts | the top of `overlay.swift` |

After editing `overlay.swift`, rebuild with the `swiftc` command above. After editing the plist, copy it to `~/Library/LaunchAgents/` again (same `sed` command) and turn it off and on.

## Troubleshooting

Errors are logged to `~/.eyecare/error.log`.

## Built with

Swift (AppKit) and a launchd LaunchAgent. No dependencies, no Xcode project.
