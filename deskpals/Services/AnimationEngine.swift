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
    private var directionChangeTimer: Timer?
    private var state: State = .idle

    private var targetSpeed: Double = 0
    private var currentSpeed: Double = 0
    private var moveAngle: Double = 0
    private var walkStartTime: TimeInterval = 0

    private let lerpFactor: Double = 2.0 // speed interpolation rate per second

    func start() {
        pickNewTarget()
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
        directionChangeTimer?.invalidate()
        directionChangeTimer = nil
    }

    func updateBounds(_ rect: CGRect) {
        bounds = rect
        position.x = position.x.clamped(to: bounds.minX...bounds.maxX)
        position.y = position.y.clamped(to: bounds.minY...bounds.maxY)
    }

    private func tick() {
        guard state == .walking else { return }

        let dt = 1.0 / 60.0

        // Smooth acceleration/deceleration via linear interpolation
        currentSpeed += (targetSpeed - currentSpeed) * min(lerpFactor * dt, 1.0)

        // Vertical bobbing: sine wave with amplitude 2-3 pts, period ~0.5s
        let elapsed = CACurrentMediaTime() - walkStartTime
        let bobAmplitude: Double = 2.5
        let bobPeriod: Double = 0.5
        let bob = bobAmplitude * sin(2.0 * .pi * elapsed / bobPeriod)

        let dx = currentSpeed * cos(moveAngle) * dt
        let dy = currentSpeed * sin(moveAngle) * dt

        position.x += dx
        position.y += dy + (bob - bobAmplitude * sin(2.0 * .pi * (elapsed - dt) / bobPeriod))

        // Wall bouncing with reflected angle
        var reflected = false
        if position.x <= bounds.minX {
            position.x = bounds.minX
            moveAngle = .pi - moveAngle
            reflected = true
        } else if position.x >= bounds.maxX {
            position.x = bounds.maxX
            moveAngle = .pi - moveAngle
            reflected = true
        }

        if position.y <= bounds.minY {
            position.y = bounds.minY
            moveAngle = -moveAngle
            reflected = true
        } else if position.y >= bounds.maxY {
            position.y = bounds.maxY
            moveAngle = -moveAngle
            reflected = true
        }

        if reflected {
            // Normalize angle to [0, 2*pi)
            moveAngle = moveAngle.truncatingRemainder(dividingBy: 2.0 * .pi)
            if moveAngle < 0 { moveAngle += 2.0 * .pi }
        }

        velocity = CGVector(dx: currentSpeed * cos(moveAngle), dy: currentSpeed * sin(moveAngle))
        facingLeft = velocity.dx < 0
        delegate?.animationEngineDidUpdatePosition(position, facingLeft: facingLeft)
    }

    private func transitionTo(_ newState: State) {
        stateTimer?.invalidate()
        directionChangeTimer?.invalidate()
        state = newState
        isWalking = (newState == .walking)
        delegate?.animationEngineDidChangeState(isWalking: isWalking)

        switch newState {
        case .walking:
            pickNewTarget()
            walkStartTime = CACurrentMediaTime()
            startDirectionChangeTimer()
            let duration = Double.random(in: 2...6)
            stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.transitionTo(.idle)
            }
        case .idle:
            targetSpeed = 0
            velocity = .zero
            let duration = Double.random(in: 1...4)
            stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.transitionTo(.walking)
            }
        }
    }

    private func startDirectionChangeTimer() {
        directionChangeTimer?.invalidate()
        // Check every 0.1s with 1% chance (≈10% per second)
        directionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.state == .walking else { return }
            if Double.random(in: 0...1) < 0.01 {
                self.pickNewTarget()
            }
        }
    }

    private func pickNewTarget() {
        targetSpeed = Double.random(in: 20...100)
        moveAngle = Double.random(in: 0...(2 * .pi))
        facingLeft = cos(moveAngle) < 0
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
