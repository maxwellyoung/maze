//
//  GameViewController.swift
//  maze
//
//  Created by Maxwell Young on 19/02/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
    }

    private func setupGame() {
        guard let view = self.view as? SKView else { return }
        
        // Configure the view
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true // Useful for debugging
        
        // Create and configure the scene
        let scene = MainMenuScene()
        scene.scaleMode = .resizeFill
        
        // Calculate scene size to maintain aspect ratio
        let screenSize = view.bounds.size
        let minDimension = min(screenSize.width, screenSize.height)
        scene.size = CGSize(width: minDimension, height: minDimension)
        
        // Present the scene
        view.presentScene(scene)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            if let view = self.view as? SKView, let scene = view.scene {
                let minDimension = min(size.width, size.height)
                scene.size = CGSize(width: minDimension, height: minDimension)
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
