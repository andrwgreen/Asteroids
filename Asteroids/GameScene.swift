//
//  GameScene.swift
//  Asteroids
//
//  Created by Andrew Green on 4/28/16.
//  Copyright (c) 2016 Andrew Green. All rights reserved.
//

import SpriteKit

// TODO: Bitmask stuff here

let shipCatagory:     UInt32 = 1 << 0
let laserCatagory:    UInt32 = 1 << 1
let asteroidCatagory: UInt32 = 1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // TODO: Put all global variables here?
    var ship: SKSpriteNode!
    var largeAsteroid: SKSpriteNode!
    var mediumAsteroid: SKSpriteNode!
    var smallAsteroid: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var particle: SKEmitterNode!
    var level = 1
    
    //Set up Buttons
    var leftButton:  SKSpriteNode!
    var rightButton: SKSpriteNode!
    var upButton:    SKSpriteNode!
    var shootButton: SKSpriteNode!
    var playAgainButton: SKLabelNode!
    var upButtonPressed = false
    var leftButtonPressed = false
    var rightButtonPressed = false
    var asteroidTimer: NSTimer!
    
    var score = 0
    var gameOver = false
    var center = CGPoint(x: 0, y: 0)
    var smallestDimensionSize: CGFloat! // for laser timer
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.scaleMode = SKSceneScaleMode.ResizeFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self  // This line is important only for physicsContactDelegate
        // self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.contactTestBitMask = 0 //nothing bounces off of the edge, it will wrap instead
        self.backgroundColor = UIColor.blackColor();
        center = CGPointMake(self.frame.width / 2, self.frame.height/2)
        
        // set smallest dimension size
        if self.frame.width > self.frame.height{
            smallestDimensionSize = self.frame.height
        }
        else{
            smallestDimensionSize = self.frame.width
        }
        
        setupGame()
        
    }

    func setupGame(){
        
        gameOver = false
        
        //Left Button
        leftButton = SKSpriteNode(texture: SKTexture(imageNamed: "RotateLeft"), size: CGSize(width: 60, height: 100))
        leftButton.position = CGPoint(x: self.frame.width*0.9-160, y: self.frame.height*0.2-20)
        leftButton.zPosition = 999
        leftButton.name = "UIElement"
        self.addChild(leftButton)
        
        
        //Up Button
        upButton = SKSpriteNode(texture: SKTexture(imageNamed: "Up"), size: CGSize(width: 140, height: 60))
        upButton.position = CGPoint(x: self.frame.width*0.9-80, y: self.frame.height*0.2+20)
        upButton.zPosition = 999
        upButton.name = "UIElement"
        self.addChild(upButton)
        
        
        //Right Button
        rightButton = SKSpriteNode(texture: SKTexture(imageNamed: "RotateRight"), size: CGSize(width: 60, height: 100))
        rightButton.position = CGPoint(x: self.frame.width*0.9, y: self.frame.height*0.2-20)
        rightButton.zPosition = 999
        rightButton.name = "UIElement"
        self.addChild(rightButton)
        
        
        //Shoot Button
        shootButton = SKSpriteNode(texture: SKTexture(imageNamed: "Fire"), size: CGSize(width: 120, height: 60))
        shootButton.position = CGPoint(x: self.frame.width*0.15, y: self.frame.height*0.2)
        shootButton.zPosition = 999
        shootButton.name = "UIElement"
        self.addChild(shootButton)
        
        // Ship setup
        ship = SKSpriteNode(imageNamed: "Ship")
        ship.position = center
        ship.zPosition = 10
        ship.zRotation = CGFloat(M_PI) / 2
        ship.size = CGSize(width: 40, height: 40)
        ship.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ship.physicsBody?.angularDamping = 1
        ship.physicsBody?.linearDamping = 0
        ship.physicsBody?.categoryBitMask = shipCatagory
        ship.physicsBody?.contactTestBitMask = asteroidCatagory
        ship.name = "ship" // Used when checking all children for wrapping
        self.addChild(ship)
        
        //particle on ship
        particle = SKEmitterNode(fileNamed: "FireParticle.sks")
        particle!.targetNode = self
        //particle position thinks ship is in top right when ship in center. fix by subtracting
        particle.position = CGPoint(x: (ship.position.x - self.frame.width/2) - 20, y: (ship.position.y-self.frame.height/2))
        particle.particleBirthRate = 0
        ship.addChild(particle!)
        
        spawnLargeAsteroid()
        
        // Set up timer
        asteroidTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.spawnLargeAsteroid), userInfo: nil, repeats: true)
        
        
        scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 18
        scoreLabel.fontName = "Futura Medium"
        scoreLabel.position = CGPoint(x: 10, y: self.frame.height - 25)
        scoreLabel.zPosition = 999
        self.addChild(scoreLabel)
        
        
    }
    
    func clearGame(){
        asteroidTimer.invalidate()
        score = 0
        scoreLabel.text = "\(score)"
        ship.removeFromParent()
        for node in self.children{
            if node.name != "UIElement"{
                node.removeFromParent()
                gameOverLabel.removeFromParent()
                playAgainButton.removeFromParent()
            }
        }
    }


    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if gameOver == false{
                // TODO: Act on touches in control boxes
                if shootButton.containsPoint(location){
                    shootLaser()
                    runAction(SKAction.playSoundFileNamed("pew_final.wav", waitForCompletion: false))
                }
                
                if upButton.containsPoint(location){
                    upButtonPressed = true
                    particle.particleBirthRate = 1000
                    particle.particlePositionRange.dy = 10
                    particle.particlePositionRange.dx = 2
                }
                if leftButton.containsPoint(location){
                    leftButtonPressed = true
                }
                else if rightButton.containsPoint(location){
                    rightButtonPressed = true
                }
            }
            
            if playAgainButton != nil{
                if playAgainButton.containsPoint(location){
                    clearGame()
                    setupGame()
                }
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
            
            if !gameOver{
                if upButton.containsPoint(location){
                    upButtonPressed = true
                    particle.particleBirthRate = 500
                    
                }
                else{
                    particle.particleBirthRate = 0
                }
                if leftButton.containsPoint(location){
                    leftButtonPressed = true
                }
                else if rightButton.containsPoint(location){
                    rightButtonPressed = true
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        leftButtonPressed = false
        rightButtonPressed = false
        upButtonPressed = false
        
        particle.particleBirthRate = 0
    }


    
    func spawnLargeAsteroid(){
        
        //set random sprite
        let rand = Int(random()*3)+1
        switch (rand){
        case 1: largeAsteroid = SKSpriteNode(imageNamed: "LargeAsteroid1")
        case 2: largeAsteroid = SKSpriteNode(imageNamed: "LargeAsteroid2")
        default: largeAsteroid = SKSpriteNode(imageNamed: "LargeAsteroid3")
        }
        
        
        //set the buffer zone
        let xBuffer = self.frame.width * 0.1
        let yBuffer = self.frame.height * 0.1
        
        var randx: CGFloat!
        var randy: CGFloat!
        
        //check if spawn is within buffer of ship. if so, redo
       repeat{

                //set spawn location for asteroid (any x, top 90% y)
                randx = random() * self.frame.width
                randy = random() * 0.9 * self.frame.height + 0.1 * self.frame.height
        }while(((randx >= (ship.position.x - xBuffer)) && (randx <= (ship.position.x + xBuffer)))
        || ((randy >= (ship.position.y - yBuffer)) && (randy <= (ship.position.y + yBuffer))))
        
        
        
        largeAsteroid.position = CGPoint(x: randx, y: randy)
        largeAsteroid.zPosition = 1
        largeAsteroid.size = CGSize(width: 100, height: 100)
        largeAsteroid.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        largeAsteroid.name = "largeAsteroid"
        largeAsteroid.physicsBody?.angularDamping = 0
        largeAsteroid.physicsBody?.linearDamping = 0
        largeAsteroid.physicsBody?.categoryBitMask = asteroidCatagory
        largeAsteroid.physicsBody?.contactTestBitMask = shipCatagory
        
        //give angular and linear velocity at default
        //angular velocity between -0.5 and 0.5
        let randAngV = random() - 0.5
        //linear velocity from -50 to 50
        let randLinVx = random() * 100 - 50
        let randLinVy = random() * 100 - 50

        
        largeAsteroid.physicsBody?.angularVelocity = randAngV
        largeAsteroid.physicsBody?.velocity = CGVector(dx: randLinVx, dy: randLinVy)
        
        self.addChild(largeAsteroid)
    }
    
    func spawnMediumAsteroid(x: CGFloat, y: CGFloat){
        
        //set random sprite
        let rand = Int(random()*3)+1
        switch (rand){
        case 1: mediumAsteroid = SKSpriteNode(imageNamed: "MediumAsteroid1")
        case 2: mediumAsteroid = SKSpriteNode(imageNamed: "MediumAsteroid2")
        default: mediumAsteroid = SKSpriteNode(imageNamed: "MediumAsteroid3")
        }

        //set position to that given in call
        //      (location of large asteroid death)
        // +/- 64
        let adjustedx = x + ((random() * 100) - 50)
        let adjustedy = y + ((random() * 100) - 50)
        
        mediumAsteroid.position = CGPoint(x: adjustedx, y: adjustedy)
        mediumAsteroid.zPosition = 1
        mediumAsteroid.size = CGSize(width: 60, height: 60)
        mediumAsteroid.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        mediumAsteroid.name = "mediumAsteroid"
        mediumAsteroid.physicsBody?.angularDamping = 0
        mediumAsteroid.physicsBody?.linearDamping = 0
        mediumAsteroid.physicsBody?.categoryBitMask = asteroidCatagory
        mediumAsteroid.physicsBody?.contactTestBitMask = shipCatagory | laserCatagory
        
        //give angular and linear velocity at default
        //angular velocity between -0.5 and 0.5
        let randAngV = random() - 0.5
        //linear velocity from -50 to 50
        let randLinVx = random() * 100 - 50
        let randLinVy = random() * 100 - 50
        
        
        mediumAsteroid.physicsBody?.angularVelocity = randAngV
        mediumAsteroid.physicsBody?.velocity = CGVector(dx: randLinVx, dy: randLinVy)
        
        self.addChild(mediumAsteroid)
    }
    
    func spawnSmallAsteroid(x: CGFloat, y: CGFloat){

        //set random sprite
        let rand = Int(random()*3)+1
        switch (rand){
        case 1: smallAsteroid = SKSpriteNode(imageNamed: "SmallAsteroid1")
        case 2: smallAsteroid = SKSpriteNode(imageNamed: "SmallAsteroid2")
        default: smallAsteroid = SKSpriteNode(imageNamed: "SmallAsteroid3")
        }
        
        //set position to that given in call
        //      (location of medium asteroid death)
        // +/- 60
        let adjustedx = x + ((random() * 60) - 30)
        let adjustedy = y + ((random() * 60) - 30)
        
        smallAsteroid.position = CGPoint(x: adjustedx, y: adjustedy)
        smallAsteroid.zPosition = 1
        smallAsteroid.size = CGSize(width: 30, height: 30)
        smallAsteroid.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        smallAsteroid.name = "smallAsteroid"
        smallAsteroid.physicsBody?.angularDamping = 0
        smallAsteroid.physicsBody?.linearDamping = 0
        smallAsteroid.physicsBody?.categoryBitMask = asteroidCatagory
        smallAsteroid.physicsBody?.contactTestBitMask = shipCatagory | laserCatagory
        
        //give angular and linear velocity at default
        //angular velocity between -0.5 and 0.5
        let randAngV = random() - 0.5
        //linear velocity from -50 to 50
        let randLinVx = random() * 100 - 50
        let randLinVy = random() * 100 - 50
        
        
        smallAsteroid.physicsBody?.angularVelocity = randAngV
        smallAsteroid.physicsBody?.velocity = CGVector(dx: randLinVx, dy: randLinVy)
        
        self.addChild(smallAsteroid)
    }

    func random() -> CGFloat{
        //return random number 0-1
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func shootLaser(){
        // TODO
        let shotVelocity: CGFloat = 200
        let laser = SKShapeNode(circleOfRadius: 2)
        laser.fillColor = UIColor.whiteColor()
        laser.position = offsetFromShip(ship.frame.height / 2)
        laser.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        laser.physicsBody?.categoryBitMask = laserCatagory
        laser.physicsBody?.contactTestBitMask = asteroidCatagory
        laser.name = "laser"
        
        let xComponent = cos(ship.zRotation) * shotVelocity
        let yComponent = sin(ship.zRotation) * shotVelocity
        
        laser.physicsBody?.velocity.dx = ship.physicsBody!.velocity.dx + xComponent
        laser.physicsBody?.velocity.dy = ship.physicsBody!.velocity.dy + yComponent
        laser.physicsBody?.linearDamping = 0
        
        self.addChild(laser)
        
        // Laser lifetime: t = d/v
        //   where t = time
        //         d = self.frame.height
        //         v = shot velocity (200)
        let d = Double(smallestDimensionSize) - Double(ship.frame.height)
        let laserAction = SKAction.sequence([SKAction.waitForDuration(d / Double(shotVelocity)), SKAction.removeFromParent()])
        laser.runAction(laserAction)
        
        
    }
    
    // Takes a vector magnitude (CGFloat) and returns a CGPoint based on the zRotation of the
    // ship. This is primarily used to calculate the point at which the laser spawns at.
    func offsetFromShip(offset: CGFloat) ->CGPoint{
        
        let x = ship.position.x + cos(ship.zRotation) * offset
        let y = ship.position.y + sin(ship.zRotation) * offset
        
        return CGPoint(x: x, y: y)
    }
    
    // Called when the left/right buttons are pressed, and applies angular velocity
    // in the desired direction
    func rotate(direction: String){
        
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
        
        let xComponent = cos(ship.zRotation) * thrust
        let yComponent = sin(ship.zRotation) * thrust
        
        ship.physicsBody?.velocity.dx += xComponent
        ship.physicsBody?.velocity.dy += yComponent
    }
    
    func asteroidDidHitShip(contact: SKPhysicsContact) -> Bool{
        
        if (contact.bodyA.categoryBitMask == shipCatagory && contact.bodyB.categoryBitMask == asteroidCatagory) ||
           (contact.bodyA.categoryBitMask == asteroidCatagory && contact.bodyB.categoryBitMask == shipCatagory){
            return true
        }
        return false
    }
    
    func laserDidHitAsteroid(contact: SKPhysicsContact) -> Bool{

        if (contact.bodyA.categoryBitMask == laserCatagory && contact.bodyB.categoryBitMask == asteroidCatagory) ||
            (contact.bodyA.categoryBitMask == asteroidCatagory && contact.bodyB.categoryBitMask == laserCatagory){
            return true
        }
        return false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
//        print("bodyA:  \(contact.bodyA.categoryBitMask)")
//        print("bodyB:  \(contact.bodyB.categoryBitMask)")
        
        if asteroidDidHitShip(contact){
            shipDestroyed()
        }
        if laserDidHitAsteroid(contact){
            laserHitAsteroid(contact)
        }
    }
    
    func laserHitAsteroid(contact: SKPhysicsContact){
        var asteroidName: String!
        var asteroidLocation: CGPoint!
        var asteroid: SKNode!
        
        //actions
        
        let shrinkAction = SKAction.scaleBy(0, duration: 1.25)
        let fadeAction = SKAction.fadeOutWithDuration(0.75)
        let removePhysicsAction = SKAction.runBlock({
            asteroid.physicsBody = nil
        })
        let removeNodeAction = SKAction.runBlock({
            asteroid.removeFromParent()
        })
        
        let goAwayAction = SKAction.group([shrinkAction, fadeAction])
        
        let explodeAction = SKAction.sequence([removePhysicsAction, goAwayAction, removeNodeAction])
        
        //verify not nil
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
        
            //determine bodyA and bodyB
            //set asteroid name, location, then remove asteroid and laser
            if (contact.bodyA.node!.name == "laser"){
                asteroid = contact.bodyB.node
                asteroidName = asteroid.name
                asteroidLocation = asteroid.position
                
                //asteroid explode
                asteroid.runAction(explodeAction)
                
                //remove laser
                contact.bodyA.node?.removeFromParent()
            } else {
                asteroid = contact.bodyA.node
                asteroidName = asteroid.name
                asteroidLocation = asteroid.position
                
                //asteroid explode
                asteroid!.runAction(explodeAction)
                
                //remove laser
                contact.bodyB.node?.removeFromParent()
            }

            
            //add smaller asteroid if one and update score
            if (asteroidName == "largeAsteroid"){
                //spawn 2 medium asteroids
                spawnMediumAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                spawnMediumAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                
                //update score
                updateScore(1)
                
            } else if (asteroidName == "mediumAsteroid"){
                //spawn 4 small asteroids
                spawnSmallAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                spawnSmallAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                spawnSmallAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                spawnSmallAsteroid(asteroidLocation.x, y: asteroidLocation.y)
                
                //update score
                updateScore(2)
                
            } else if (asteroidName == "smallAsteroid"){
                //update score
                updateScore(4)
            }
        } 
    }

    
    func updateScore(valueToAdd: Int){
        score += valueToAdd
        scoreLabel.text = "\(score)"
    }
    
    func shipDestroyed(){
        // TODO: Add more than one life after the end of the semester
        // All of this will go into that function
        gameEnd()
        
    }
    
    func gameEnd(){
        leftButton.removeFromParent()
        rightButton.removeFromParent()
        upButton.removeFromParent()
        shootButton.removeFromParent()
        asteroidTimer.invalidate()
        

        
        
        let shrinkAction = SKAction.scaleBy(0, duration: 1.25)
        let fadeAction = SKAction.fadeOutWithDuration(0.75)
        let removePhysicsAction = SKAction.runBlock({
            self.ship.physicsBody = nil
        })
        let removeNodeAction = SKAction.runBlock({
            self.ship.removeFromParent()
        })
        let goAwayAction = SKAction.group([shrinkAction, fadeAction])
        
        let delayAction = SKAction.waitForDuration(1)
        
        let gameOverLabelAction = SKAction.runBlock({
            self.gameOverLabel = SKLabelNode(text: "Game Over!")
            self.gameOverLabel.fontName = "Futura Medium"
            self.gameOverLabel.fontSize = 48
            self.gameOverLabel.color = UIColor.whiteColor()
            self.gameOverLabel.position = self.center
            self.gameOverLabel.zPosition = 999
            self.gameOverLabel.name = "UIElement"
            self.addChild(self.gameOverLabel)
        })
        let playAgainButtonAction = SKAction.runBlock({
            self.playAgainButton = SKLabelNode(text: "Play Again")
            self.playAgainButton.fontName = "Futura Medium"
            self.playAgainButton.fontSize = 32
            self.playAgainButton.color = UIColor.whiteColor()
            self.playAgainButton.position.x = self.frame.width/2
            self.playAgainButton.position.y = self.frame.height/4
            self.playAgainButton.zPosition = 999
            self.playAgainButton.name = "UIElement"
            self.addChild(self.playAgainButton)
        })
        
        let changeAsteroidsToJTAction = SKAction.runBlock({
            for case let child as SKSpriteNode in self.children{
                if ((child.name?.containsString("Asteroid")) == true){
                    child.texture = SKTexture(imageNamed: "JThurman")
                }
            }
        })
        
        
        let gameOverAction = SKAction.sequence([removePhysicsAction, goAwayAction, gameOverLabelAction, delayAction, playAgainButtonAction, changeAsteroidsToJTAction, removeNodeAction])
        
        
        self.ship.runAction(gameOverAction)
        gameOver = true

        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Ship movement related things
        particle.emissionAngle = ship.zRotation - CGFloat(M_PI)
        
        if upButtonPressed{
            thrust()
        }
        if leftButtonPressed{
            rotate("left")
        }
        else if rightButtonPressed{
            rotate("right")
        }
        
        // Edge wrapping things
        
        for node in self.children{
            
            if node.name != "UIElement"{
                
                if node.position.x < self.frame.minX{
                    node.position.x = self.frame.maxX
                }
                if node.position.x > self.frame.maxX{
                    node.position.x = self.frame.minX
                }
                
                
                if node.position.y < self.frame.minY{
                    node.position.y = self.frame.maxY
                }
                if node.position.y > self.frame.maxY{
                    node.position.y = self.frame.minY
                }
            }
        }
    }
}
