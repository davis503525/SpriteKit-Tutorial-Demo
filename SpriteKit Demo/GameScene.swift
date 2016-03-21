//
//  GameScene.swift
//  SpriteKit Demo
//
//  Created by Davis Allie on 12/03/16.
//  Copyright (c) 2016 tutsplus. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Direction {
    case Left, Right
}

class LaneState: GKState {
    var playerNode: SKNode
    
    init(player: SKNode) {
        self.playerNode = player
    }
}

class LeftLane: LaneState {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        if stateClass == MiddleLane.self {
            return true
        }
        
        return false
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        let moveAction = SKAction.moveToX(90.0, duration: 0.3)
        self.playerNode.constraints = []
        self.playerNode.removeActionForKey("horizontalMovement")
        
        let completion = SKAction.runBlock { () -> Void in
            let constraint = SKConstraint.positionX(SKRange(constantValue: 90.0))
            self.playerNode.constraints = [constraint]
        }
        
        let newAction = SKAction.sequence([moveAction, completion])
        self.playerNode.runAction(newAction, withKey: "horizontalMovement")
    }
}

class MiddleLane: LaneState {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        if stateClass == LeftLane.self || stateClass == RightLane.self {
            return true
        }
        
        return false
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        let moveAction = SKAction.moveToX(160.0, duration: 0.3)
        self.playerNode.constraints = []
        self.playerNode.removeActionForKey("horizontalMovement")
        
        let completion = SKAction.runBlock { () -> Void in
            let constraint = SKConstraint.positionX(SKRange(constantValue: 160.0))
            self.playerNode.constraints = [constraint]
        }
        
        let newAction = SKAction.sequence([moveAction, completion])
        self.playerNode.runAction(newAction, withKey: "horizontalMovement")
    }
}

class RightLane: LaneState {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        if stateClass == MiddleLane.self {
            return true
        }
        
        return false
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        let moveAction = SKAction.moveToX(230.0, duration: 0.3)
        self.playerNode.constraints = []
        self.playerNode.removeActionForKey("horizontalMovement")
        
        let completion = SKAction.runBlock { () -> Void in
            let constraint = SKConstraint.positionX(SKRange(constantValue: 230.0))
            self.playerNode.constraints = [constraint]
        }
        
        let newAction = SKAction.sequence([moveAction, completion])
        self.playerNode.runAction(newAction, withKey: "horizontalMovement")
    }
}

class LaneStateMachine: GKStateMachine {

}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var playerNode: SKNode?
    var baseWall: SKNode?
    
    var currentWallSet = 0
    
    var spawnSideWall: NSTimer!
    var spawnObstacle: NSTimer!
    
    var acceptMoveControl = true
    var stateMachine: GKStateMachine!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)*/
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.speed = 0.9999
        
        self.playerNode = self.childNodeWithName("PlayerSprite")
        self.baseWall = self.childNodeWithName("BaseWall")
        
        let constraint = SKConstraint.positionX(SKRange(constantValue: 160.0))
        self.playerNode?.constraints = [constraint]
        self.playerNode?.physicsBody?.contactTestBitMask = 0x00000011
        
        let moveForwardAction = SKAction.moveByX(0, y: 50.0, duration: 0.5)
        self.playerNode?.runAction(SKAction.repeatActionForever(moveForwardAction))
        
        self.spawnInSideWallSet()
        self.spawnSideWall = NSTimer(timeInterval: moveForwardAction.duration*9, target: self, selector: "spawnInSideWallSet", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(spawnSideWall, forMode: NSRunLoopCommonModes)
        
        self.spawnObstacle = NSTimer(timeInterval: 3.0, target: self, selector: "spawnInObstacle", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(spawnObstacle, forMode: NSRunLoopCommonModes)
                
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.spawnInSideWallSet()
        
        // Don't try to set up camera constraints if we don't yet have a camera.
        let camera = SKCameraNode()
        self.camera = camera
        camera.position = self.playerNode!.position
        addChild(camera)
        print(camera.position)
        print(self.playerNode?.position)
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let playerLocationConstraint = SKConstraint.distance(zeroRange, toNode: playerNode!)
        let xConstraint = SKConstraint.positionX(SKRange(constantValue: 160.0))
        
        camera.constraints = [playerLocationConstraint, xConstraint]
        
        self.stateMachine = GKStateMachine(states: [LeftLane(player: self.playerNode!), MiddleLane(player: self.playerNode!), RightLane(player: self.playerNode!)])
        self.stateMachine.enterState(MiddleLane.self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        /*for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
    }
    
    func moveInDirection(direction: Direction) {
        guard let playerNode = self.playerNode else { return }
        
        playerNode.constraints = []
        
        if (direction == .Right && self.stateMachine.currentState is LeftLane) ||
         (direction == .Left && self.stateMachine.currentState is RightLane) {
            self.stateMachine.enterState(MiddleLane.self)
        } else if self.stateMachine.currentState is MiddleLane {
            switch direction {
            case .Left:
                self.stateMachine.enterState(LeftLane.self)
            case .Right:
                self.stateMachine.enterState(RightLane.self)
            }
        }
        
        /*var x = 0.0
        if playerNode.position.x == 160.0 {
            x = direction == .Left ? 90.0 : 230.0
        } else if playerNode.position.x == 230.0 && direction == .Left {
            x = 160.0
        } else if playerNode.position.x == 90.0 && direction == .Right {
            x = 160.0
        } else {
            x = Double(playerNode.position.x)
        }
        
        let moveAction = SKAction.moveToX(CGFloat(x), duration: 0.3)
        playerNode.runAction(moveAction) { () -> Void in
            let constraint = SKConstraint.positionX(SKRange(constantValue: CGFloat(x)))
            playerNode.constraints = [constraint]
            self.acceptMoveControl = true
        }*/
    }
    
    func spawnInSideWallSet() {
        for i in 0...1 {
            let x = i == 0 ? 0 : 280
            let y = (self.currentWallSet) * 480
            let wall = SKShapeNode(rect: CGRect(x: x, y: y, width: 40, height: 480))
            wall.fillColor = UIColor.whiteColor()
            wall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 480))
            wall.physicsBody?.affectedByGravity = false
            wall.physicsBody?.pinned = true
            wall.physicsBody?.contactTestBitMask = 0x00000000
            wall.physicsBody?.allowsRotation = false
            
            //wall.position = CGPoint(x: x, y: y)
            
            self.addChild(wall)
        }
        
        self.currentWallSet += 1
    }
    
    func spawnInObstacle() {
        let obstacle = SKShapeNode(circleOfRadius: 15)
        obstacle.fillColor = UIColor.redColor()
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        obstacle.physicsBody?.contactTestBitMask = 0x00000010
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.pinned = true
        
        var spawnPoint = CGPoint(x: 160.0, y: self.playerNode!.position.y + 1000)
        
        let generator = GKShuffledDistribution(lowestValue: 1, highestValue: 3)
        switch generator.nextInt() {
        case 1:
            spawnPoint.x = 90.0
        case 2:
            spawnPoint.x = 160.0
        case 3:
            spawnPoint.x = 230.0
        default:
            break
        }
        
        obstacle.position = spawnPoint
        self.addChild(obstacle)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //print(self.playerNode?.position.y)
        /*if self.playerNode?.position.y == CGFloat((self.currentWallSet-1)*480-50) {
            self.spawnInSideWallSet()
        }*/
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA == self.playerNode?.physicsBody || contact.bodyB == self.playerNode?.physicsBody {
            let path = NSBundle.mainBundle().pathForResource("Explosion", ofType: "sks")
            let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
            
            explosion.position = self.playerNode!.position
            
            //self.camera?.position = explosion.position
            self.camera?.constraints = []
            self.camera?.runAction(SKAction.moveTo(explosion.position, duration: 0.3))
            
            self.spawnSideWall.invalidate()
            self.spawnObstacle.invalidate()
            
            self.playerNode?.removeFromParent()
            self.addChild(explosion)
        }
    }
}
