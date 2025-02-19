import SpriteKit
import CoreMotion

class PhysicsEngine {
    private let motionManager = CMMotionManager()
    private let gravityMagnitude: Double = 9.81 // Standard gravity in m/s²
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        // Use device motion instead of just accelerometer for more accurate tilt data
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz update rate
    }
    
    func startPhysicsSimulation(updateHandler: @escaping (CGVector) -> Void) {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, let self = self else { return }
            
            // Get the device's attitude (orientation)
            let gravity = motion.gravity
            
            // Calculate tilt angles
            // Roll (left/right tilt) affects X movement
            // Pitch (forward/back tilt) affects Y movement
            let roll = gravity.x  // Left/right tilt
            let pitch = gravity.y // Forward/back tilt
            
            // Scale the tilt to create appropriate force
            // We use a non-linear response curve for more precise control
            let scaledForce = self.calculateForceFromTilt(roll: roll, pitch: pitch)
            
            // Apply the force vector
            updateHandler(scaledForce)
        }
    }
    
    private func calculateForceFromTilt(roll: Double, pitch: Double) -> CGVector {
        // Apply a dead zone for when the device is nearly flat
        let deadZone = 0.1
        
        // Calculate force magnitudes with dead zone
        let dx = abs(roll) < deadZone ? 0 : roll
        let dy = abs(pitch) < deadZone ? 0 : pitch
        
        // Apply non-linear scaling for more precise control
        let scaleFactor = 12.0 // Adjust this to control sensitivity
        let scaledDx = pow(dx, 3) * scaleFactor // Cubic response curve
        let scaledDy = pow(dy, 3) * scaleFactor
        
        return CGVector(
            dx: scaledDx * gravityMagnitude,
            dy: scaledDy * gravityMagnitude
        )
    }
    
    func stopPhysicsSimulation() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // Configure physics body for the marble
    func configureMarblePhysics(for node: SKNode) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        node.physicsBody?.allowsRotation = true
        node.physicsBody?.restitution = 0.3    // Less bouncy
        node.physicsBody?.friction = 0.4       // More friction
        node.physicsBody?.linearDamping = 0.5  // Moderate damping for natural movement
        node.physicsBody?.angularDamping = 0.7 // More angular damping for stability
        node.physicsBody?.mass = 1.0          // Standard mass
        
        // Set maximum velocities
        let maxVelocity: CGFloat = 1000.0
        let maxAngularVelocity: CGFloat = 20.0
        
        // Apply velocity limits in the update loop
        node.physicsBody?.velocity = CGVector(
            dx: min(maxVelocity, abs(node.physicsBody?.velocity.dx ?? 0)) * (node.physicsBody?.velocity.dx ?? 0 >= 0 ? 1 : -1),
            dy: min(maxVelocity, abs(node.physicsBody?.velocity.dy ?? 0)) * (node.physicsBody?.velocity.dy ?? 0 >= 0 ? 1 : -1)
        )
        
        node.physicsBody?.angularVelocity = min(maxAngularVelocity, abs(node.physicsBody?.angularVelocity ?? 0)) * 
            ((node.physicsBody?.angularVelocity ?? 0) >= 0 ? 1 : -1)
    }
    
    // Configure physics body for walls
    func configureWallPhysics(for node: SKNode) {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.restitution = 0.1 // Very little bounce
        node.physicsBody?.friction = 0.6    // High friction
        
        // Make sure walls don't move
        node.physicsBody?.pinned = true
        node.physicsBody?.allowsRotation = false
    }
} 