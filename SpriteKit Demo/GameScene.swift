//
//  GameScene.swift
//  SpriteKit Demo
//
//  Created by Davis Allie on 12/03/16.
//  Copyright (c) 2016 tutsplus. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var playerNode: SKNode?
    var baseWall: SKNode?
    
    var currentWallSet = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)*/
        
        self.playerNode = self.childNodeWithName("PlayerSprite")
        self.baseWall = self.childNodeWithName("BaseWall")
        
        let constraint = SKConstraint.positionX(SKRange(constantValue: 160.0))
        self.playerNode?.constraints = [constraint]
        
        let moveForwardAction = SKAction.moveByX(0, y: 50.0, duration: 0.5)
        self.playerNode?.runAction(SKAction.repeatActionForever(moveForwardAction))
        
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
        
        camera.constraints = [playerLocationConstraint]
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
    
    func spawnInSideWallSet() {
        for i in 0...1 {
            let x = i == 0 ? 0 : 280
            let y = (self.currentWallSet+1) * 600
            let wall = SKShapeNode(rect: CGRect(x: x, y: y, width: 40, height: 480))
            wall.fillColor = UIColor.whiteColor()
            wall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 480))
            wall.physicsBody?.affectedByGravity = false
            wall.physicsBody?.pinned = true
            wall.physicsBody?.contactTestBitMask = 0x00000001
            
            self.addChild(wall)
        }
        
        self.currentWallSet += 1
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
