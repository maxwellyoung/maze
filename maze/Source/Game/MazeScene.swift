import SpriteKit
import GameplayKit

class MazeScene: SKScene {
    private let physicsEngine = PhysicsEngine()
    private lazy var levelManager = LevelManager(physicsEngine: physicsEngine)
    private var marble: SKNode?
    private var cameraNode: SKCameraNode?
    private var currentLevel: Int = 1
    private var levelTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var timerLabel: SKLabelNode?
    private var levelLabel: SKLabelNode?
    private var endNode: SKNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupCamera()
        setupPhysicsWorld()
        setupMarble()
        setupUI()
        setupParticleEffects()
        setupLevel()
        startPhysicsSimulation()
        
        lastUpdateTime = Date().timeIntervalSince1970
    }
    
    private func setupCamera() {
        let camera = SKCameraNode()
        camera.setScale(1.0)
        self.camera = camera
        self.cameraNode = camera
        addChild(camera)
        
        // Add UI container to camera
        let uiContainer = SKNode()
        uiContainer.position = CGPoint(x: -frame.width/2 + 20, y: frame.height/2 - 20)
        camera.addChild(uiContainer)
        
        // Back button with modern design
        let backButton = createButton(text: "×", size: CGSize(width: 40, height: 40))
        backButton.position = .zero
        uiContainer.addChild(backButton)
    }
    
    private func setupParticleEffects() {
        guard let marble = marble else { return }
        
        // Trail effect
        let trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "spark")
        trail.particleBirthRate = 20
        trail.particleLifetime = 0.5
        trail.particleSpeed = 0
        trail.particleSpeedRange = 20
        trail.particleAlpha = 0.3
        trail.particleAlphaRange = 0.2
        trail.particleScale = 0.1
        trail.particleScaleRange = 0.05
        trail.particleColor = .red
        trail.targetNode = self
        marble.addChild(trail)
        
        // Ambient particles
        let ambient = SKEmitterNode()
        ambient.particleTexture = SKTexture(imageNamed: "spark")
        ambient.particleBirthRate = 1
        ambient.particleLifetime = 2.0
        ambient.particleSpeed = 30
        ambient.particleSpeedRange = 10
        ambient.particleAlpha = 0.2
        ambient.particleAlphaRange = 0.1
        ambient.particleScale = 0.1
        ambient.particleScaleRange = 0.05
        ambient.particleColor = .white
        ambient.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(ambient)
    }
    
    private func setupUI() {
        guard let camera = cameraNode else { return }
        
        // Level indicator with modern design
        let levelContainer = SKNode()
        levelContainer.position = CGPoint(x: 0, y: frame.height/2 - 50)
        
        let levelBg = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 20)
        levelBg.fillColor = .black
        levelBg.strokeColor = .red
        levelBg.lineWidth = 2
        levelBg.alpha = 0.8
        levelContainer.addChild(levelBg)
        
        levelLabel = SKLabelNode(text: "LEVEL \(currentLevel)")
        levelLabel?.fontName = "AvenirNext-Bold"
        levelLabel?.fontSize = 24
        levelLabel?.fontColor = .white
        levelLabel?.verticalAlignmentMode = .center
        levelContainer.addChild(levelLabel!)
        
        camera.addChild(levelContainer)
        
        // Timer with modern design
        let timerContainer = SKNode()
        timerContainer.position = CGPoint(x: 0, y: frame.height/2 - 100)
        
        let timerBg = SKShapeNode(rectOf: CGSize(width: 120, height: 30), cornerRadius: 15)
        timerBg.fillColor = .black
        timerBg.strokeColor = .red
        timerBg.lineWidth = 1
        timerBg.alpha = 0.6
        timerContainer.addChild(timerBg)
        
        timerLabel = SKLabelNode(text: "00:00")
        timerLabel?.fontName = "AvenirNext-Medium"
        timerLabel?.fontSize = 20
        timerLabel?.fontColor = .white
        timerLabel?.verticalAlignmentMode = .center
        timerContainer.addChild(timerLabel!)
        
        camera.addChild(timerContainer)
    }
    
    private func setupMarble() {
        // Create marble with modern design
        let marbleRadius: CGFloat = 10
        let marble = SKShapeNode(circleOfRadius: marbleRadius)
        marble.fillColor = .red
        marble.strokeColor = .white
        marble.lineWidth = 1
        marble.position = CGPoint(x: -80, y: -80)
        marble.zPosition = 1
        marble.name = "marble"
        
        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2.0])
        
        let glowShape = SKShapeNode(circleOfRadius: marbleRadius + 2)
        glowShape.fillColor = .red
        glowShape.strokeColor = .clear
        glowShape.alpha = 0.5
        glow.addChild(glowShape)
        
        marble.addChild(glow)
        
        // Add inner highlight
        let highlight = SKShapeNode(circleOfRadius: marbleRadius * 0.5)
        highlight.fillColor = .white
        highlight.strokeColor = .clear
        highlight.alpha = 0.3
        highlight.position = CGPoint(x: -marbleRadius * 0.2, y: marbleRadius * 0.2)
        marble.addChild(highlight)
        
        physicsEngine.configureMarblePhysics(for: marble)
        
        addChild(marble)
        self.marble = marble
    }
    
    private func createButton(text: String, size: CGSize) -> SKNode {
        let container = SKNode()
        
        let button = SKShapeNode(rectOf: size, cornerRadius: size.width/2)
        button.fillColor = .black
        button.strokeColor = .red
        button.lineWidth = 2
        button.name = text.lowercased()
        
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = size.width * 0.6
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = text.lowercased()
        
        button.addChild(label)
        container.addChild(button)
        
        return container
    }
    
    private func startPhysicsSimulation() {
        physicsEngine.startPhysicsSimulation { [weak self] force in
            self?.physicsWorld.gravity = CGVector(dx: force.dx * 2, dy: force.dy * 2)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update timer
        levelTimer += currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        let minutes = Int(levelTimer) / 60
        let seconds = Int(levelTimer) % 60
        timerLabel?.text = String(format: "%02d:%02d", minutes, seconds)
        
        // Check if marble fell into a hole
        if let marble = marble, marble.position.y < -200 {
            resetMarble()
        }
        
        // Check win condition
        if let marble = marble, let endNode = endNode {
            let distance = hypot(marble.position.x - endNode.position.x,
                               marble.position.y - endNode.position.y)
            if distance < 20 { // Win radius of 20 points
                handleLevelComplete()
            }
        }
        
        // Update camera with smooth damping
        if let marble = marble, let camera = cameraNode {
            let deltaX = marble.position.x - camera.position.x
            let deltaY = marble.position.y - camera.position.y
            camera.position.x += deltaX * 0.1
            camera.position.y += deltaY * 0.1
        }
    }
    
    private func resetMarble() {
        guard let marble = marble else { return }
        
        // Add reset animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let reset = SKAction.run { [weak self] in
            marble.position = CGPoint(x: -80, y: -80)
            marble.physicsBody?.velocity = .zero
            marble.physicsBody?.angularVelocity = 0
        }
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        
        marble.run(SKAction.sequence([fadeOut, reset, fadeIn]))
        
        // Add particle burst
        let burst = SKEmitterNode()
        burst.particleTexture = SKTexture(imageNamed: "spark")
        burst.particleBirthRate = 100
        burst.particleLifetime = 0.5
        burst.particleSpeed = 100
        burst.particleSpeedRange = 50
        burst.particleAlpha = 0.5
        burst.particleAlphaRange = 0.2
        burst.particleScale = 0.1
        burst.particleScaleRange = 0.05
        burst.particleColor = .red
        burst.position = marble.position
        burst.targetNode = self
        
        addChild(burst)
        burst.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()]))
    }
    
    private func handleLevelComplete() {
        // Stop physics
        physicsEngine.stopPhysicsSimulation()
        
        // Create celebration effect
        let celebration = SKEmitterNode()
        celebration.particleTexture = SKTexture(imageNamed: "spark")
        celebration.particleBirthRate = 100
        celebration.particleLifetime = 2.0
        celebration.particleSpeed = 200
        celebration.particleSpeedRange = 100
        celebration.particleAlpha = 0.8
        celebration.particleAlphaRange = 0.2
        celebration.particleScale = 0.2
        celebration.particleScaleRange = 0.1
        celebration.particleColorBlendFactor = 1.0
        celebration.particleBlendMode = .add
        
        // Create multiple colors for particles
        let colors: [UIColor] = [.red, .yellow, .green, .blue, .purple]
        let sequence = SKAction.sequence(
            colors.map { color in
                SKAction.run { celebration.particleColor = color }
            } + [SKAction.wait(forDuration: 0.2)]
        )
        celebration.run(SKAction.repeatForever(sequence))
        
        celebration.position = marble?.position ?? CGPoint(x: frame.midX, y: frame.midY)
        addChild(celebration)
        
        // Add victory text
        let victoryText = SKLabelNode(text: "LEVEL COMPLETE!")
        victoryText.fontName = "AvenirNext-Bold"
        victoryText.fontSize = 36
        victoryText.fontColor = .white
        victoryText.position = CGPoint(x: 0, y: 100)
        camera?.addChild(victoryText)
        
        // Add time text
        let timeText = SKLabelNode(text: "Time: \(timerLabel?.text ?? "00:00")")
        timeText.fontName = "AvenirNext-Medium"
        timeText.fontSize = 24
        timeText.fontColor = .white
        timeText.position = CGPoint(x: 0, y: 50)
        camera?.addChild(timeText)
        
        // Add continue button
        let continueButton = createButton(text: "CONTINUE", size: CGSize(width: 200, height: 50))
        continueButton.position = CGPoint(x: 0, y: -50)
        camera?.addChild(continueButton)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Disable marble physics
        marble?.physicsBody?.isDynamic = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "×" {
                returnToMainMenu()
            } else if node.name == "continue" {
                loadNextLevel()
            }
        }
    }
    
    private func returnToMainMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorway(withDuration: 0.8))
    }
    
    private func loadNextLevel() {
        currentLevel += 1
        let nextScene = MazeScene(size: size)
        nextScene.currentLevel = currentLevel
        nextScene.scaleMode = .aspectFill
        view?.presentScene(nextScene, transition: SKTransition.doorway(withDuration: 0.8))
    }
    
    private func setupLevel() {
        if !levelManager.loadLevel(currentLevel, in: self) {
            print("Failed to load level \(currentLevel)")
        }
        
        // Find and store the end node
        endNode = childNode(withName: "end_marker")
    }
}

extension MazeScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions with visual and haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
} 