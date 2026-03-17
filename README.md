# rest-in-pixels 👻

A ghostly eye care reminder for macOS.

Every 20 minutes, a full-screen overlay takes over your screen with an animated ASCII ghost and a random fun fact — forcing you to rest your eyes.

- **20-20-20 rule** — look at something 20 feet away
- **20-second lockout** — can't dismiss early
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

## Uninstall

```bash
# stop the scheduler
launchctl unload ~/Library/LaunchAgents/com.eyecare.reminder.plist

# remove the launch agent
rm ~/Library/LaunchAgents/com.eyecare.reminder.plist

# delete the app
rm -rf ~/.eyecare
```

## How it works

### The big picture

A macOS LaunchAgent runs the compiled Swift binary every **20 minutes** (1200 seconds). The binary creates a full-screen black overlay on every connected monitor, plays an ASCII ghost animation, shows a random fact, and locks you out for 20 seconds. After that, press any key or click to dismiss.

### Files

| File | What it does |
|---|---|
| `overlay.swift` | The entire app — one self-contained Swift file, no Xcode project needed |
| `frames.json` | 235 ASCII art frames that make up the ghost animation (array of string arrays) |
| `facts.json` | Pool of random fun facts shown during the break |
| `com.eyecare.reminder.plist` | macOS LaunchAgent config — tells the system to run the binary every 1200s |
| `rest-in-pixels` | Compiled arm64 binary (built from overlay.swift) |
| `error.log` | Stderr output from the binary, useful for debugging |

### How overlay.swift works

**1. Window setup (lines 183–213)**

The app creates a borderless, full-screen `NSWindow` on every connected screen. Each window sits at the highest possible window level (`maximumWindow`) so nothing can cover it. The window joins all Spaces and works alongside fullscreen apps.

```
NSWindow.Level = maximumWindow  →  sits above everything
collectionBehavior = canJoinAllSpaces + fullScreenAuxiliary
activationPolicy = .accessory  →  no dock icon
```

**2. Animation engine (lines 136–161)**

Two timers run simultaneously:
- **Frame timer** at 30fps — cycles through all 235 frames in `frames.json`, looping forever
- **Countdown timer** at 1s intervals — ticks down from 20 to 0, then unlocks dismissal

Both start the moment the overlay appears. No fade-in delay.

**3. Rendering (lines 72–124)**

Every frame, `draw()` is called. It:
- Fills the screen black
- Draws the current ASCII ghost frame in **cyan at 30% opacity** (centered)
- Draws "look away. 20 feet. breathe." in off-white below the ghost
- Draws a random fact in dim purple-gray
- Shows either a **pink progress bar** (`█░░░░ 18s`) or **green "press any key"** when done

**4. Dismissal (lines 126–134)**

- **Escape key** always quits immediately (safety valve — prevents getting stuck after sleep)
- **Any other key or mouse click** quits only after the countdown reaches 0

**5. Sleep handling (lines 215–220)**

Listens for `NSWorkspace.willSleepNotification`. If the Mac goes to sleep, the app terminates itself. This prevents a frozen overlay when you wake up.

### The color palette (synthwave)

| Color | RGB | Used for |
|---|---|---|
| Black | `(0, 0, 0)` | Background |
| Off-white | `(0.855, 0.851, 0.78)` | Main text |
| Cyan | `(0.071, 0.765, 0.886)` | Ghost animation |
| Pink | `(0.965, 0.094, 0.561)` | Countdown bar |
| Green | `(0.118, 0.733, 0.169)` | "press any key" |
| Dim gray | `(0.498, 0.439, 0.58)` | Fun fact text |

### The LaunchAgent

`com.eyecare.reminder.plist` tells macOS to:
- Run `~/.eyecare/rest-in-pixels` every **1200 seconds** (20 minutes)
- Start immediately on load (`RunAtLoad = true`)
- Log errors to `~/.eyecare/error.log`

The plist uses `__HOME__` as a placeholder — replace it with your actual home path if needed.

### Tweaking

| Want to change... | Edit this |
|---|---|
| Break interval | `StartInterval` in the plist (value in seconds) |
| Lockout duration | `countdown: Int = 20` in overlay.swift (line 11) |
| Progress bar width | `let filled = 20 - countdown` in overlay.swift (line 118) — keep in sync with countdown |
| Font | `monoFont` / `monoSmall` / `frameFont` declarations (lines 32–37) |
| Colors | The synthwave palette block (lines 25–30) |
| Facts | Add/remove entries in `facts.json` |

After editing overlay.swift, recompile:

```bash
cd ~/.eyecare
swiftc -O -o rest-in-pixels overlay.swift -framework Cocoa
```

No need to reload the LaunchAgent — it spawns a fresh process each time.

## Requirements

- macOS
- Xcode Command Line Tools (`xcode-select --install`)
