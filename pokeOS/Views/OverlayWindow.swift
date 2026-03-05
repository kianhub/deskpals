import AppKit

class OverlayWindow: NSWindow {
    private let overlayContentView: OverlayContentView

    init(contentRect: NSRect) {
        overlayContentView = OverlayContentView(frame: contentRect)

        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        isReleasedWhenClosed = false
        contentView = overlayContentView

        loadInitialSprite()
    }

    private func loadInitialSprite() {
        if let image = SpriteLoader.loadSprite(name: "pikachu", gen: 1, isShiny: false, isWalking: false) {
            overlayContentView.updateSpriteImage(image)
            let spriteSize = overlayContentView.spriteView.frame.size
            let centerX = (frame.width - spriteSize.width) / 2
            let centerY = (frame.height - spriteSize.height) / 2
            overlayContentView.updateSpritePosition(NSPoint(x: centerX, y: centerY))
        }
    }
}
