//
//  GameScene.swift
//  Asteroids
//
//  Created by Andrew Green on 4/28/16.
//  Copyright (c) 2016 Andrew Green. All rights reserved.
//

import SpriteKit

// TODO: Bitmask stuff here

class GameScene: SKScene {
    
    // TODO: Put all global variables here?
    var ship: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var particle: SKEmitterNode!
    
    //Set up Buttons
    var leftButton:  SKShapeNode!
    var rightButton: SKShapeNode!
    var upButton:    SKShapeNode!
    var shootButton: SKShapeNode!
    var upButtonPressed = false
    var leftButtonPressed = false
    var rightButtonPressed = false
    
    var score = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.scaleMode = SKSceneScaleMode.ResizeFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        // self.physicsWorld.contactDelegate = self  // This line is important only for physicsContactDelegate
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.backgroundColor = UIColor.blackColor();
        
        // TODO: Set up control boxes
        
        //Left Button
        leftButton = SKShapeNode(rectOfSize: CGSize(width: 40, height: 80))
        leftButton.position = CGPoint(x: self.frame.width*0.9-120, y: self.frame.height*0.2-20)
        leftButton.zPosition = 999
        leftButton.fillColor = UIColor.clearColor()
        leftButton.strokeColor = UIColor.redColor()
        leftButton.lineWidth = 3
        self.addChild(leftButton)
        
        //Up Button
        upButton = SKShapeNode(rectOfSize: CGSize(width: 160, height: 40))
        upButton.position = CGPoint(x: self.frame.width*0.9-60, y: self.frame.height*0.2)
        upButton.zPosition = 999
        upButton.fillColor = UIColor.clearColor()
        upButton.strokeColor = UIColor.whiteColor()
        upButton.lineWidth = 3
        self.addChild(upButton)
        
        
        //Right Button
        rightButton = SKShapeNode(rectOfSize: CGSize(width: 40, height: 80))
        rightButton.position = CGPoint(x: self.frame.width*0.9, y: self.frame.height*0.2-20)
        rightButton.zPosition = 999
        rightButton.fillColor = UIColor.clearColor()
        rightButton.strokeColor = UIColor.blueColor()
        rightButton.lineWidth = 3
        self.addChild(rightButton)


        
        //Shoot Button
        shootButton = SKShapeNode(rectOfSize: CGSize(width: 120, height: 40))
        shootButton.position = CGPoint(x: self.frame.width*0.15, y: self.frame.height*0.1)
        shootButton.zPosition = 999
        shootButton.fillColor = UIColor.clearColor()
        shootButton.strokeColor = UIColor.yellowColor()
        shootButton.lineWidth = 3
        self.addChild(shootButton)

        
        
        
        // TODO: Set up ship
        ship = SKSpriteNode(imageNamed: "Ship")
        ship.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        ship.zPosition = 1
        ship.size = CGSize(width: 40, height: 40)
        ship.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ship.physicsBody?.angularDamping = 1
        self.addChild(ship)
        
        //particle on ship
        particle = SKEmitterNode(fileNamed: "FireParticle.sks")
        particle!.targetNode = self
            //particle position thinks ship is in top right when ship in center. fix by subtracting
        particle.position = CGPoint(x: ship.position.x - self.frame.width/2, y: (ship.position.y-self.frame.height/2)-20)
        ship.addChild(particle!)
        
        
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            // TODO: Act on touches in control boxes
            if upButton.containsPoint(location){
                upButtonPressed = true
            }
            if leftButton.containsPoint(location){
                leftButtonPressed = true
            }
            else if rightButton.containsPoint(location){
                rightButtonPressed = true
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Control to see if a button is still pressed
        // Aslways assume a button is not being pressed
        // until proven otherwise
        leftButtonPressed = false
        rightButtonPressed = false
        upButtonPressed = false
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            // If any button contains a touch point, then it is still being
            // pressed, so the button action will still be applied at the next frame
            
            if upButton.containsPoint(location){
                upButtonPressed = true
            }
            if leftButton.containsPoint(location){
                leftButtonPressed = true
            }
            else if rightButton.containsPoint(location){
                rightButtonPressed = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        leftButtonPressed = false
        rightButtonPressed = false
        upButtonPressed = false
    }
    
    func spawnAsteroid(){
        // TODO
    }
    
    func fireLaser(){
        // TODO
    }
    
    func rotate(direction: String){
        // TODO
        // The CGFloat is the degree change (in radians) in angular velocity
        
        if direction == "right"{
            ship.physicsBody?.angularVelocity -= CGFloat(0.075)
        }
        else{
            ship.physicsBody?.angularVelocity += CGFloat(0.075)
        }
        
    }
    
    func thrust(){
        // TODO
        
        // Thrust magnitude, to be broken down into x/y components
        let thrust = CGFloat(5)
        
        let xComponent = cos(ship.zRotation + CGFloat(M_PI) / 2) * thrust
        let yComponent = sin(ship.zRotation + CGFloat(M_PI) / 2) * thrust
        
        ship.physicsBody?.velocity.dx += xComponent
        ship.physicsBody?.velocity.dy += yComponent
    }
    
    func shotHit(){
        // TODO
    }
    
    func shipHit(){
        // TODO
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        particle.emissionAngle = ship.zRotation - 0.5 * CGFloat(M_PI)
        
        if upButtonPressed{
            thrust()
        }
        
        if leftButtonPressed{
            rotate("left")
        }
        else if rightButtonPressed{
            rotate("right")
        }
        
    }
}
