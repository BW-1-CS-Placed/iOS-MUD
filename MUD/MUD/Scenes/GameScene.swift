//
//  GameScene.swift
//  MUD
//
//  Created by Jordan Christensen on 3/3/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var playerNode: SKSpriteNode!
    var mapNode: SKTileMapNode!
    let cameraNode = SKCameraNode()
    
    var playerSpeed: TimeInterval = 0.5
    
    override func sceneDidLoad() {
        setUp()
        layoutScene()
    }
    
    func setUp() {
        if let map = self.childNode(withName: "Map") as? SKTileMapNode, let tileSet = SKTileSet(named: "Sample Grid Tile Set") {
            let noiseMap = createNoiseMap()
            map.enableAutomapping = true
            for col in 0..<map.numberOfColumns {
                for row in 0..<map.numberOfRows {
                    let val = noiseMap.value(at: vector2(Int32(row),Int32(col)))
                    switch val {
                    case -1.0..<(-0.5):
                        if let g = tileSet.tileGroups.first(where: {
                            ($0.name ?? "") == "Water"}) {
                            map.setTileGroup(g, forColumn: col, row: row)
                        }
                    default:
                        if let g = tileSet.tileGroups.first(where: {
                            ($0.name ?? "") == "Grass"}) {
                            map.setTileGroup(g, forColumn: col, row: row)
                        }
                    }
                 }
            }
            self.mapNode = map
        }
        
        if let somePlayer = self.childNode(withName: "Player") as? SKSpriteNode {
            playerNode = somePlayer
            playerNode.physicsBody?.isDynamic = true
            playerNode.physicsBody?.affectedByGravity = false
        }
        
        addChild(cameraNode)
        camera = cameraNode
    }
    
    @objc
    func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            moveLeft()
        } else if sender.direction == .right {
            moveRight()
        } else if sender.direction == .up {
            moveUp()
        } else if sender.direction == .down {
            moveDown()
        }
    }
    
    override func didMove(to view: SKView) {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            
        upSwipe.direction = .up
        downSwipe.direction = .down
        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
    }
    
    func moveUp() {
        let moveAction = SKAction.moveBy(x: 0, y: 128, duration: playerSpeed)
        playerNode.run(moveAction)
    }
    
    func moveDown() {
        let moveAction = SKAction.moveBy(x: 0, y: -128, duration: playerSpeed)
        playerNode.run(moveAction)
    }
    
    func moveLeft() {
        let moveAction = SKAction.moveBy(x: -128, y: 0, duration: playerSpeed)
        playerNode.run(moveAction)
    }
    
    func moveRight() {
        let moveAction = SKAction.moveBy(x: 128, y: 0, duration: playerSpeed)
        playerNode.run(moveAction)
    }
    
    
    func touchDown(atPoint pos: CGPoint) {
//        let x = pos.x - playerNode.position.x
//        let y = pos.y - playerNode.position.y
//        let val = abs(y) / abs(x)
//        if val > 0.7 {
//            if pos.y > 0 {
//                moveUp()
//            } else {
//                moveDown()
//            }
//        } else {
//           if pos.x > 0 {
//                moveRight()
//            } else {
//                moveLeft()
//            }
//        }
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        
    }
    
    func touchUp(atPoint pos: CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchDown(atPoint: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchMoved(toPoint: touch.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchUp(atPoint: touch.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchUp(atPoint: touch.location(in: self))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position = playerNode.position
    }
    
    func layoutScene() {
        
    }
    
    func createNoiseMap() -> GKNoiseMap {
        let noiseSource = GKPerlinNoiseSource()
        let noise = GKNoise(noiseSource)
        let noiseMap = GKNoiseMap(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(50, 50), seamless: true)
        return noiseMap
    }
}
