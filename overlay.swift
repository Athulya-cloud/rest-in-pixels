import Cocoa
import Foundation

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class OverlayView: NSView {
    var fact: String = ""
    var countdown: Int = 20
    var canDismiss = false
    var countdownTimer: Timer?
    var frameTimer: Timer?
    var countdownStarted = false
    var textAlpha: CGFloat = 0.0
    var fadeTimer: Timer?

    // Animation
    var frames: [[String]] = []
    var currentFrame: Int = 0
    var loopCount: Int = 0

    // Synthwave palette
    let bg      = NSColor(red: 0.0,  green: 0.0,  blue: 0.0,  alpha: 1.0)
    let fg      = NSColor(red: 0.855, green: 0.851, blue: 0.78, alpha: 1.0)
    let cyan    = NSColor(red: 0.071, green: 0.765, blue: 0.886, alpha: 1.0)
    let pink    = NSColor(red: 0.965, green: 0.094, blue: 0.561, alpha: 1.0)
    let green   = NSColor(red: 0.118, green: 0.733, blue: 0.169, alpha: 1.0)
    let dimGray = NSColor(red: 0.498, green: 0.439, blue: 0.58,  alpha: 1.0)

    let monoFont = NSFont(name: "JetBrains Mono", size: 15)
        ?? NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
    let monoSmall = NSFont(name: "JetBrains Mono", size: 12)
        ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    let frameFont = NSFont(name: "JetBrains Mono", size: 9)
        ?? NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)

    override var acceptsFirstResponder: Bool { true }

    func drawCentered(_ text: String, color: NSColor, font: NSFont, at y: CGFloat) {
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font
        ]
        let str = NSAttributedString(string: text, attributes: attrs)
        let size = str.size()
        str.draw(at: NSPoint(x: (bounds.width - size.width) / 2, y: y))
    }

    func drawWrapped(_ text: String, color: NSColor, font: NSFont, at y: CGFloat, maxWidth: CGFloat) -> CGFloat {
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        para.lineSpacing = 3
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font,
            .paragraphStyle: para
        ]
        let str = NSAttributedString(string: text, attributes: attrs)
        let rect = str.boundingRect(
            with: NSSize(width: maxWidth, height: 300),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let x = (bounds.width - maxWidth) / 2
        str.draw(with: NSRect(origin: NSPoint(x: x, y: y - rect.height),
                               size: NSSize(width: maxWidth, height: rect.height)),
                  options: [.usesLineFragmentOrigin, .usesFontLeading])
        return rect.height
    }

    override func draw(_ dirtyRect: NSRect) {
        bg.setFill()
        dirtyRect.fill()

        guard !frames.isEmpty else { return }

        let cx = bounds.midX
        let cy = bounds.midY

        // Draw current animation frame
        let frame = frames[currentFrame]
        let lineH: CGFloat = 11
        let totalH = CGFloat(frame.count) * lineH
        var y = cy + totalH / 2 + 80

        let ghostColor = cyan.withAlphaComponent(0.3)
        for line in frame {
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: ghostColor,
                .font: frameFont
            ]
            let str = NSAttributedString(string: line, attributes: attrs)
            let size = str.size()
            str.draw(at: NSPoint(x: cx - size.width / 2, y: y))
            y -= lineH
        }

        // Text below
        y -= 20

        drawCentered("look away. 20 feet. breathe.",
                     color: fg.withAlphaComponent(textAlpha),
                     font: monoFont, at: y)
        y -= 35

        let maxW: CGFloat = min(bounds.width * 0.6, 550)
        let factH = drawWrapped(fact,
                                color: dimGray.withAlphaComponent(textAlpha * 0.8),
                                font: monoSmall, at: y, maxWidth: maxW)
        y -= (factH + 20)

        if canDismiss {
            drawCentered("press any key",
                         color: green.withAlphaComponent(textAlpha),
                         font: monoSmall, at: y)
        } else if countdownStarted {
            let filled = 20 - countdown
            let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: countdown)
            drawCentered("\(bar)  \(countdown)s",
                         color: pink.withAlphaComponent(textAlpha * 0.7),
                         font: monoSmall, at: y)
        }
    }

    override func keyDown(with event: NSEvent) {
        // Escape always force-quits (safety valve if frozen after sleep)
        if event.keyCode == 53 { NSApplication.shared.terminate(nil) }
        if canDismiss { NSApplication.shared.terminate(nil) }
    }

    override func mouseDown(with event: NSEvent) {
        if canDismiss { NSApplication.shared.terminate(nil) }
    }

    func startAnimation() {
        // Start everything at once — countdown + text visible immediately
        textAlpha = 1.0
        countdownStarted = true

        // 30fps frame animation
        frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentFrame += 1
            if self.currentFrame >= self.frames.count {
                self.currentFrame = 0
            }
            self.needsDisplay = true
        }

        // Countdown starts immediately
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.countdown -= 1
            if self.countdown <= 0 {
                self.canDismiss = true
                self.countdownTimer?.invalidate()
            }
            self.needsDisplay = true
        }
    }
}

func loadFrames() -> [[String]] {
    let path = NSString(string: "~/.eyecare/frames.json").expandingTildeInPath
    guard let data = FileManager.default.contents(atPath: path),
          let frames = try? JSONSerialization.jsonObject(with: data) as? [[String]] else {
        return []
    }
    return frames
}

func loadFact() -> String {
    let path = NSString(string: "~/.eyecare/facts.json").expandingTildeInPath
    guard let data = FileManager.default.contents(atPath: path),
          let facts = try? JSONSerialization.jsonObject(with: data) as? [String],
          !facts.isEmpty else {
        return "your eyes can distinguish about 10 million different colors."
    }
    return facts[Int.random(in: 0..<facts.count)]
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let frames = loadFrames()
var windows: [OverlayWindow] = []

for screen in NSScreen.screens {
    let window = OverlayWindow(
        contentRect: screen.frame,
        styleMask: .borderless,
        backing: .buffered,
        defer: false
    )
    window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
    window.isOpaque = true
    window.backgroundColor = .black
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let overlay = OverlayView(frame: screen.frame)
    overlay.frames = frames
    overlay.fact = loadFact()
    window.contentView = overlay
    window.makeKeyAndOrderFront(nil)

    if screen == NSScreen.main {
        window.makeFirstResponder(overlay)
        overlay.startAnimation()
    }

    windows.append(window)
}

// Quit if system goes to sleep — prevents frozen overlay on wake
NSWorkspace.shared.notificationCenter.addObserver(
    forName: NSWorkspace.willSleepNotification,
    object: nil, queue: .main) { _ in
    NSApplication.shared.terminate(nil)
}

app.activate(ignoringOtherApps: true)
app.run()
