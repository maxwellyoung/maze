import Foundation

struct LevelJSON: Codable {
    let id: Int
    let name: String
    let description: String
    let walls: [[[Double]]]
    let startPosition: Position
    let endPosition: Position
    let obstacles: [ObstacleJSON]
}

struct Position: Codable {
    let x: Double
    let y: Double
}

struct ObstacleJSON: Codable {
    let type: String
    let position: Position
    let rotation: Double
}

class LevelLoader {
    static func loadLevel(_ levelNumber: Int) -> LevelData? {
        guard let url = Bundle.main.url(forResource: "level\(levelNumber)",
                                      withExtension: "json",
                                      subdirectory: "Levels") else {
            print("Could not find level\(levelNumber).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let levelJSON = try decoder.decode(LevelJSON.self, from: data)
            
            return convertToLevelData(levelJSON)
        } catch {
            print("Error loading level: \(error)")
            return nil
        }
    }
    
    private static func convertToLevelData(_ json: LevelJSON) -> LevelData {
        // Convert walls from [[Double]] to [CGPoint]
        let walls = json.walls.map { wallPoints in
            wallPoints.map { point in
                CGPoint(x: point[0], y: point[1])
            }
        }
        
        // Convert start and end positions
        let startPosition = CGPoint(x: json.startPosition.x, y: json.startPosition.y)
        let endPosition = CGPoint(x: json.endPosition.x, y: json.endPosition.y)
        
        // Convert obstacles
        let obstacles = json.obstacles.map { obstacle in
            ObstacleData(
                type: convertObstacleType(obstacle.type),
                position: CGPoint(x: obstacle.position.x, y: obstacle.position.y),
                rotation: CGFloat(obstacle.rotation)
            )
        }
        
        return LevelData(
            walls: walls,
            startPosition: startPosition,
            endPosition: endPosition,
            obstacles: obstacles
        )
    }
    
    private static func convertObstacleType(_ type: String) -> ObstacleType {
        switch type {
        case "hole":
            return .hole
        case "bumper":
            return .bumper
        case "movingPlatform":
            return .movingPlatform
        default:
            return .hole // Default to hole as fallback
        }
    }
} 