import AppKit

class OverlayContentView: NSView {
    let spriteView = SpriteImageView()
    private let highlightView = NSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupHighlightView()
        addSubview(spriteView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHighlightView()
        addSubview(spriteView)
    }

    private func setupHighlightView() {
        highlightView.wantsLayer = true
        highlightView.layer?.backgroundColor = NSColor.systemRed.withAlphaComponent(0.15).cgColor
        highlightView.layer?.cornerRadius = 8
        highlightView.layer?.borderColor = NSColor.systemRed.withAlphaComponent(0.3).cgColor
        highlightView.layer?.borderWidth = 1.5
        highlightView.isHidden = true
        addSubview(highlightView)
    }

    override func layout() {
        super.layout()
        highlightView.frame = bounds
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        let localPoint = convert(point, from: superview)
        if spriteView.frame.contains(localPoint) {
            return spriteView
        }
        return nil
    }

    func setHighlightVisible(_ visible: Bool) {
        highlightView.isHidden = !visible
    }

    func updateSpritePosition(_ point: NSPoint) {
        spriteView.frame.origin = point
    }

    func updateSpriteImage(_ image: NSImage) {
        spriteView.updateSprite(image: image)
    }
}
