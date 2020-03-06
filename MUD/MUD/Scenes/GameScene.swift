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
    var mapArray = [[Room?]]()
    var cameraNode: SKCameraNode!
    var tileSet: SKTileSet = SKTileSet(named: "Sample Grid Tile Set")!
    
    var currentRoom: Room?
    var apiController: APIController? {
        didSet {
            setUp()
        }
    }
    var rooms = [Room]()
    var playerSpeed: TimeInterval = 0.5
    
    var house: SKTileGroup!
    var water: SKTileGroup!
    
    override func sceneDidLoad() {
        setUp()
        layoutScene()
    }
    
    func setUp() {
        guard let apiController = apiController else { return }
        house = tileSet.tileGroups.first(where: { ($0.name ?? "") == "House" })!
        water = tileSet.tileGroups.first(where: { ($0.name ?? "") == "Water" })!
        let range = 0..<100
        for col in range {
            mapArray.append([])
            for _ in range {
                mapArray[col].append(nil)
            }
        }
        
        if let map = self.childNode(withName: "Map") as? SKTileMapNode {
            mapNode = map
        }
        refreshMap()
        
        if let somePlayer = self.childNode(withName: "Player") as? SKSpriteNode {
            playerNode = somePlayer
            playerNode.physicsBody?.isDynamic = true
            playerNode.physicsBody?.affectedByGravity = false
            apiController.fetchPlayerLocation { result in
                switch result {
                case .success(let name):
                    self.setRoom(with: name)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        if let someCamera = self.childNode(withName: "Camera") as? SKCameraNode {
            cameraNode = someCamera
            camera = cameraNode
        }
    }
    
    func refreshMap() {
        guard let map = mapNode, let apiController = apiController else { return }
        apiController.fetchRooms { result in
            switch result {
            case .success(let rooms):
                self.rooms = rooms
                if let room = rooms.first {
                    self.recurseMap(room: room, col: map.numberOfColumns / 2, row: map.numberOfRows / 2)
                    guard let position = self.getLocationOfRoom(with: self.currentRoom?.title ?? "") else { return }
                    DispatchQueue.main.async {
                        self.playerNode.position = map.centerOfTile(atColumn: position.col, row: position.row)
                    }
                }
            case .failure(let error):
                print("\(error)")
            }
        }

    }
    
    func recurseMap(room: Room, col: Int, row: Int) {
        
        mapNode.setTileGroup(house, forColumn: col, row: row)
        mapArray[col][row] = room
        
        let north = mapNode.tileGroup(atColumn: col + 1, row: row) != nil
        let south = mapNode.tileGroup(atColumn: col - 1, row: row) != nil
        let east = mapNode.tileGroup(atColumn: col, row: row + 1) != nil
        let west = mapNode.tileGroup(atColumn: col, row: row - 1) != nil
        if (north || room.north == 0) && (south || room.south == 0) && (east || room.east == 0) && (west || room.west == 0) {
            fillWithWater()
            return
        }
        
        if !north, room.north != 0, let newRoom = getRoom(with: room.north) {
            recurseMap(room: newRoom, col: col + 1, row: row)
        }
        if !south, room.south != 0, let newRoom = getRoom(with: room.south) {
            recurseMap(room: newRoom, col: col - 1, row: row)
        }
        if !east, room.east != 0, let newRoom = getRoom(with: room.east) {
            recurseMap(room: newRoom, col: col, row: row + 1)
        }
        if !west, room.west != 0, let newRoom = getRoom(with: room.west) {
            recurseMap(room: newRoom, col: col, row: row - 1)
        }
    }
    
    func fillWithWater() {
        for col in 0..<mapNode.numberOfColumns {
            for row in 0..<mapNode.numberOfRows {
                if mapNode.tileGroup(atColumn: col, row: row) == nil {
                    mapNode.setTileGroup(water, forColumn: col, row: row)
                }
            }
        }
    }
    
    func getRandomPosition() -> CGPoint {
        var x = -1
        var y = -1
        
        while mapNode.tileGroup(atColumn: y, row: x)?.name ?? "" != "House" {
            y = Int.random(in: 1..<mapNode.numberOfColumns)
            x = Int.random(in: 1..<mapNode.numberOfRows)
        }
        
        return CGPoint(x: (x * 64), y: (y * 64))
    }
    
    @objc
    func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            move(direction: .west)
        } else if sender.direction == .right {
            move(direction: .east)
        } else if sender.direction == .up {
            move(direction: .north)
        } else if sender.direction == .down {
            move(direction: .south)
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
    
    func move(direction: Direction) {
        let distance = mapNode.tileSize.height
        let moveAction: SKAction
        switch direction {
        case .north:
            moveAction = SKAction.moveBy(x: 0, y: distance, duration: playerSpeed)
        case .south:
            moveAction = SKAction.moveBy(x: 0, y: -distance, duration: playerSpeed)
        case .east:
            moveAction = SKAction.moveBy(x: distance, y: 0, duration: playerSpeed)
        case .west:
            moveAction = SKAction.moveBy(x: -distance, y: 0, duration: playerSpeed)
        }
        
        apiController?.move(Direction.north, completion: { (result) in
            switch result {
            case .success(let roomName):
                if self.setRoom(with: roomName) {
                    self.playerNode.run(moveAction)
                } else {
                    print("Could not find room!")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @discardableResult
    func setRoom(with name: String) -> Bool {
        var roomFound = false
        for room in rooms {
            if room.title == name {
                currentRoom = room
                roomFound = true
            }
        }
        return roomFound
    }
    
    func getRoom(with id: Int) -> Room? {
        for room in rooms {
            if room.id == id {
                return room
            }
        }
        return nil
    }
    
    func getLocationOfRoom(with name: String) -> (row: Int, col: Int)? {
        for col in 0..<mapArray.count {
            for row in 0..<mapArray[col].count {
                if mapArray[col][row]?.title == name {
                    return (row, col)
                }
            }
        }
        return nil
    }
    
    func touchDown(atPoint pos: CGPoint) {
        
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
        DispatchQueue.main.async {
            self.cameraNode.position = self.playerNode.position
        }
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
