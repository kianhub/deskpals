import AppKit

class OverlayContentView: NSView {
    let spriteView = SpriteImageView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(spriteView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(spriteView)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        let localPoint = convert(point, from: superview)
        if spriteView.frame.contains(localPoint) {
            return spriteView
        }
        return nil
    }

    func updateSpritePosition(_ point: NSPoint) {
        spriteView.frame.origin = point
    }

    func updateSpriteImage(_ image: NSImage) {
        spriteView.updateSprite(image: image)
    }
}
