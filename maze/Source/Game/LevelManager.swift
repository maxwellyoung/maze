import SpriteKit

struct LevelData {
    let walls: [[CGPoint]]
    let startPosition: CGPoint
    let endPosition: CGPoint
    let obstacles: [ObstacleData]
}

struct ObstacleData {
    let type: ObstacleType
    let position: CGPoint
    let rotation: CGFloat
}

enum ObstacleType {
    case hole
    case bumper
    case movingPlatform
}

class LevelManager {
    private var currentLevel: Int = 1
    private let physicsEngine: PhysicsEngine
    
    init(physicsEngine: PhysicsEngine) {
        self.physicsEngine = physicsEngine
    }
    
    func loadLevel(_ level: Int, in scene: SKScene) -> Bool {
        guard let levelData = LevelLoader.loadLevel(level) else { return false }
        
        // Clear existing level
        scene.children.filter { $0 is SKShapeNode }.forEach { $0.removeFromParent() }
        
        // Add walls
        for wallPoints in levelData.walls {
            createWall(from: wallPoints, in: scene)
        }
        
        // Add obstacles
        for obstacle in levelData.obstacles {
            createObstacle(from: obstacle, in: scene)
        }
        
        // Add start and end markers
        createMarker(at: levelData.startPosition, color: .green, in: scene)
        createMarker(at: levelData.endPosition, color: .red, in: scene)
        
        currentLevel = level
        return true
    }
    
    private func createWall(from points: [CGPoint], in scene: SKScene) {
        let path = CGMutablePath()
        path.move(to: points[0])
        
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        let wall = SKShapeNode(path: path)
        wall.strokeColor = .white
        wall.lineWidth = 3
        wall.lineCap = .round
        wall.lineJoin = .round
        wall.name = "wall"
        
        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2.0])
        
        let glowPath = SKShapeNode(path: path)
        glowPath.strokeColor = .white.withAlphaComponent(0.3)
        glowPath.lineWidth = 5
        glowPath.lineCap = .round
        glowPath.lineJoin = .round
        glow.addChild(glowPath)
        
        wall.addChild(glow)
        
        physicsEngine.configureWallPhysics(for: wall)
        scene.addChild(wall)
    }
    
    private func createObstacle(from data: ObstacleData, in scene: SKScene) {
        let obstacle: SKShapeNode
        
        switch data.type {
        case .hole:
            obstacle = SKShapeNode(circleOfRadius: 15)
            obstacle.fillColor = .black
            obstacle.strokeColor = .red
            obstacle.glowWidth = 3
            obstacle.name = "hole"
            
        case .bumper:
            obstacle = SKShapeNode(circleOfRadius: 10)
            obstacle.fillColor = .red
            obstacle.strokeColor = .white
            obstacle.glowWidth = 2
            obstacle.name = "bumper"
            
        case .movingPlatform:
            obstacle = SKShapeNode(rectOf: CGSize(width: 60, height: 10))
            obstacle.fillColor = .red.withAlphaComponent(0.7)
            obstacle.strokeColor = .white
            obstacle.glowWidth = 2
            obstacle.name = "platform"
            
            // Add movement animation
            let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1)
            let moveDown = moveUp.reversed()
            let sequence = SKAction.sequence([moveUp, moveDown])
            obstacle.run(SKAction.repeatForever(sequence))
        }
        
        obstacle.position = data.position
        obstacle.zRotation = data.rotation
        
        scene.addChild(obstacle)
    }
    
    private func createMarker(at position: CGPoint, color: SKColor, in scene: SKScene) {
        let marker = SKShapeNode(circleOfRadius: 5)
        marker.fillColor = color
        marker.strokeColor = .white
        marker.glowWidth = 2
        marker.position = position
        marker.name = "marker"
        scene.addChild(marker)
    }
} 