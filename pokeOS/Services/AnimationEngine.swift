import AppKit
import Combine

protocol AnimationEngineDelegate: AnyObject {
    func animationEngineDidUpdatePosition(_ position: CGPoint, facingLeft: Bool)
    func animationEngineDidChangeState(isWalking: Bool)
}

class AnimationEngine: ObservableObject {
    enum State {
        case walking
        case idle
    }

    weak var delegate: AnimationEngineDelegate?

    @Published var position: CGPoint = .zero
    @Published var isWalking: Bool = false
    @Published var facingLeft: Bool = false

    var velocity: CGVector = .zero
    var bounds: CGRect = .zero

    private var timer: Timer?
    private var stateTimer: Timer?
    private var state: State = .idle

    func start() {
        pickNewVelocity()
        transitionTo(.walking)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        stateTimer?.invalidate()
        stateTimer = nil
    }

    func updateBounds(_ rect: CGRect) {
        bounds = rect
        position.x = position.x.clamped(to: bounds.minX...bounds.maxX)
        position.y = position.y.clamped(to: bounds.minY...bounds.maxY)
    }

    private func tick() {
        guard state == .walking else { return }

        position.x += velocity.dx / 60.0
        position.y += velocity.dy / 60.0

        if position.x <= bounds.minX {
            position.x = bounds.minX
            velocity.dx = abs(velocity.dx)
        } else if position.x >= bounds.maxX {
            position.x = bounds.maxX
            velocity.dx = -abs(velocity.dx)
        }

        if position.y <= bounds.minY {
            position.y = bounds.minY
            velocity.dy = abs(velocity.dy)
        } else if position.y >= bounds.maxY {
            position.y = bounds.maxY
            velocity.dy = -abs(velocity.dy)
        }

        facingLeft = velocity.dx < 0
        delegate?.animationEngineDidUpdatePosition(position, facingLeft: facingLeft)
    }

    private func transitionTo(_ newState: State) {
        stateTimer?.invalidate()
        state = newState
        isWalking = (newState == .walking)
        delegate?.animationEngineDidChangeState(isWalking: isWalking)

        switch newState {
        case .walking:
            pickNewVelocity()
            let duration = Double.random(in: 2...5)
            stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.transitionTo(.idle)
            }
        case .idle:
            velocity = .zero
            let duration = Double.random(in: 1...3)
            stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.transitionTo(.walking)
            }
        }
    }

    private func pickNewVelocity() {
        let speed = Double.random(in: 30...80)
        let angle = Double.random(in: 0...(2 * .pi))
        velocity = CGVector(dx: speed * cos(angle), dy: speed * sin(angle))
        facingLeft = velocity.dx < 0
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
