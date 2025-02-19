import SpriteKit

class MainMenuScene: SKScene {
    private var glowContainer: SKEffectNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupTitle()
        setupMenuButtons()
    }
    
    private func setupBackground() {
        // Create animated background particles
        let particles = SKEmitterNode()
        particles.particleTexture = SKTexture(imageNamed: "spark") // You'll need to add this to Assets
        particles.particleBirthRate = 2
        particles.particleLifetime = 4.0
        particles.particleSpeed = 50
        particles.particleSpeedRange = 20
        particles.particleAlpha = 0.3
        particles.particleAlphaRange = 0.2
        particles.particleScale = 0.2
        particles.particleScaleRange = 0.1
        particles.particleColor = .red
        particles.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(particles)
        
        // Add subtle glow effect container
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10.0])
        addChild(glow)
        self.glowContainer = glow
    }
    
    private func setupTitle() {
        let titleContainer = SKNode()
        
        // Main title
        let title = SKLabelNode(text: "SECRET")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 52
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 20)
        titleContainer.addChild(title)
        
        // Subtitle
        let subtitle = SKLabelNode(text: "MAZE PROJECT")
        subtitle.fontName = "AvenirNext-DemiBold"
        subtitle.fontSize = 28
        subtitle.fontColor = .red
        subtitle.position = CGPoint(x: 0, y: -20)
        titleContainer.addChild(subtitle)
        
        // Position the container
        titleContainer.position = CGPoint(x: frame.midX, y: frame.maxY - 150)
        
        // Add glow effect
        let titleGlow = title.copy() as! SKLabelNode
        titleGlow.fontColor = .red
        titleGlow.alpha = 0.3
        titleGlow.setScale(1.1)
        glowContainer?.addChild(titleGlow)
        
        addChild(titleContainer)
        
        // Animate title
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.5)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.5)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        titleContainer.run(SKAction.repeatForever(sequence))
    }
    
    private func setupMenuButtons() {
        let buttonData = [
            ("PLAY", frame.midY + 80),
            ("LEVELS", frame.midY),
            ("SETTINGS", frame.midY - 80)
        ]
        
        for (index, (text, yPos)) in buttonData.enumerated() {
            let button = createButton(text: text, position: CGPoint(x: frame.midX, y: yPos))
            button.alpha = 0.0
            button.setScale(0.5)
            
            // Animate button appearance
            let delay = TimeInterval(index) * 0.15
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let group = SKAction.group([fadeIn, scaleUp])
            button.run(SKAction.sequence([SKAction.wait(forDuration: delay), group]))
            
            addChild(button)
        }
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        
        // Button background with gradient
        let button = SKShapeNode(rectOf: CGSize(width: 220, height: 50), cornerRadius: 25)
        button.fillColor = .black
        button.strokeColor = .red
        button.lineWidth = 2
        button.name = text.lowercased()
        
        // Add inner glow
        let innerGlow = button.copy() as! SKShapeNode
        innerGlow.fillColor = .clear
        innerGlow.strokeColor = .red
        innerGlow.alpha = 0.3
        innerGlow.setScale(0.95)
        button.addChild(innerGlow)
        
        // Button text
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = text.lowercased()
        
        // Add hover effect
        let hover = SKAction.customAction(withDuration: 0) { node, _ in
            let scale = SKAction.scale(to: 1.1, duration: 0.2)
            let glow = SKAction.customAction(withDuration: 0) { node, _ in
                if let shape = node as? SKShapeNode {
                    shape.glowWidth = 8
                }
            }
            node.run(SKAction.group([scale, glow]))
        }
        
        button.addChild(label)
        container.addChild(button)
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let name = node.name {
                handleButtonTap(name)
            }
        }
    }
    
    private func handleButtonTap(_ buttonName: String) {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Add tap animation
        if let button = childNode(withName: "//\(buttonName)")?.parent {
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            
            button.run(sequence) {
                switch buttonName {
                case "play":
                    self.loadGame(level: 1)
                case "levels":
                    self.showLevelSelect()
                case "settings":
                    self.showSettings()
                default:
                    break
                }
            }
        }
    }
    
    private func loadGame(level: Int) {
        let gameScene = MazeScene(size: size)
        gameScene.scaleMode = .aspectFill
        
        let transition = SKTransition.doorway(withDuration: 0.8)
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func showLevelSelect() {
        // TODO: Implement level select screen with grid layout
    }
    
    private func showSettings() {
        // TODO: Implement settings screen with animations
    }
} 