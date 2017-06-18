//
//  GameScene.swift
//  poopscoop
//
//  Created by Christopher Ho on 2017-06-07.
//  Copyright © 2017 chovo. All rights reserved.
//

import SpriteKit
import GameplayKit

//make score public so you can accessible at end of game 
var score = 0

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var textureAtlas = SKTextureAtlas()
    var textureArray = [SKTexture]()
    var counterForBubbleGunUpgrade = 0
    var bubbleGunOn = false
    var bubbleGunUpgradeDropOnScreen = false
    var currentGameState = gameState.preGame
    var numberOfLives = 3
    var difficultyLevel = 0
    var scoop = SKSpriteNode(imageNamed: "scoop")
    var bubbleUpgradeTimer: Timer!
    var colorOfGun = 0
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let scoopCategory: UInt32 = 0b1 // 1
        static let fireBubbleCategory: UInt32 = 0x10 //2
        static let poopCategory: UInt32 = 0x011 //3
        static let orangeBubbleDropCategory: UInt32 = 0x100 //4
        static let purpleBubbleDropCategory: UInt32 = 0x101 // 5
    }
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    
    let tapToStartLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    let gameDescriptionLabel1 = SKSpriteNode(imageNamed: "scoopdescription")
    let gameDescriptionLabel2 = SKSpriteNode(imageNamed: "orangebubblegundescription")
    let gameDescriptionLabel3 = SKSpriteNode(imageNamed: "purplebubblegundescription")
    let scoreLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    let counterLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    let numberOfLivesLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    
    // init game area bounds
    var gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //generate random number in given range
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func randomInt(lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    
    // stuff that happens when you tap on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        
    }
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        self.physicsWorld.contactDelegate = self
        
        score = 0
        
        //create the animation textures for the bubble guns
        textureAtlas = SKTextureAtlas(named: "playericons")
        
        for i in 1...textureAtlas.textureNames.count{
            let Name = "player\(i).png"
            textureArray.append(SKTexture(imageNamed: Name))
        }
        
        
        //init background, for loop makes it seem likes its moving
        for i in 0...1{
            
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.name = "background"
        background.anchorPoint = CGPoint(x: 0.5, y: 0)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
        background.zPosition = -1
        self.addChild(background)
            
        }
            
        //init scoop player
       // var scoop = SKSpriteNode(imageNamed: textureAtlas.textureNames[0] as! String)
        scoop.position = CGPoint(x: self.frame.midX, y: 0 - scoop.size.height)
        scoop.setScale(0.9)
        scoop.zPosition = 1
        scoop.physicsBody = SKPhysicsBody(rectangleOf: scoop.size)
        scoop.physicsBody!.affectedByGravity = false
        scoop.physicsBody!.categoryBitMask = PhysicsCategories.scoopCategory
        scoop.physicsBody!.collisionBitMask = 0
        scoop.physicsBody!.contactTestBitMask = PhysicsCategories.orangeBubbleDropCategory | PhysicsCategories.poopCategory
        
        self.addChild(scoop)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: gameArea.maxX * 0.2, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        numberOfLivesLabel.text = "Lives: 3"
        numberOfLivesLabel.fontSize = 80
        numberOfLivesLabel.fontColor = SKColor.white
        numberOfLivesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        numberOfLivesLabel.position = CGPoint(x: gameArea.maxX * 0.95, y: self.size.height + numberOfLivesLabel.frame.size.height)
        numberOfLivesLabel.zPosition = 100
        self.addChild(numberOfLivesLabel)
        
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.15)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
    
        gameDescriptionLabel1.zPosition = 1
        gameDescriptionLabel1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.75)
        gameDescriptionLabel1.setScale(2.2)
        self.addChild(gameDescriptionLabel1)
        
        gameDescriptionLabel2.zPosition = 1
        gameDescriptionLabel2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        gameDescriptionLabel2.setScale(2.2)
        self.addChild(gameDescriptionLabel2)
        
        gameDescriptionLabel3.zPosition = 1
        gameDescriptionLabel3.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
        gameDescriptionLabel3.setScale(2.2)
        self.addChild(gameDescriptionLabel3)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
        let moveOnToScreenActionFromTop = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenActionFromTop)
        numberOfLivesLabel.run(moveOnToScreenActionFromTop)
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 300
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "background", using: {background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        })
    }
    
    // finger drag to move player icon
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                scoop.position.x += amountDragged
            }
            
            // set bounds for player screen in x-direction
            if scoop.position.x > gameArea.maxX - scoop.size.width/2{
                scoop.position.x = gameArea.maxX - scoop.size.width/2
            }
            
            if scoop.position.x < gameArea.minX + scoop.size.width/2{
                scoop.position.x = gameArea.minX + scoop.size.width/2
            }
        }
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        gameDescriptionLabel1.run(deleteSequence)
        gameDescriptionLabel2.run(deleteSequence)
        gameDescriptionLabel3.run(deleteSequence)
        
        
        let moveScoopOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.1, duration: 0.5)
        let startLevelAction = SKAction.run(changeDifficultyLevel)
        let startGunSpawns = SKAction.run(startRandomSpawnBubbleGuns)
        let startGameSequence = SKAction.sequence([moveScoopOntoScreenAction, startLevelAction, startGunSpawns])
        scoop.run(startGameSequence)
    }
    
    func addScore(){
        score += 1
        scoreLabel.text = "Score: \(score)"
        
        if score == 25 || score == 50 || score == 75 || score == 100 || score == 200{
            changeDifficultyLevel()
        }
    }
    
    func decreaseLives(){
        numberOfLives -= 1
        numberOfLivesLabel.text = "Score: \(numberOfLives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        numberOfLivesLabel.run(scaleSequence)
        
        if numberOfLives == 0{
            gameOver()
        }
    }
    
    func createCounter(colorOfGun: Int){
        bubbleUpgradeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        counterLabel.fontSize = 60
        counterLabel.fontColor = SKColor.white
        counterLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        counterLabel.position = CGPoint(x: gameArea.maxX * 0.2, y: -200)
        counterLabel.zPosition = 100
        self.addChild(counterLabel)
        let moveOnToScreenActionFromBottom = SKAction.moveTo(y: self.size.height * 0.1, duration: 0.3)
        counterLabel.run(moveOnToScreenActionFromBottom)
    }
    
    func updateCounter(){
        if counterForBubbleGunUpgrade > 0{
            
             counterLabel.text = "\(counterForBubbleGunUpgrade)"
            counterForBubbleGunUpgrade -= 1
        }else {
            scoop.run(SKAction.animate(with: [textureArray[0]], timePerFrame: 0))
            bubbleGunOn = false
            bubbleGunUpgradeDropOnScreen = false
            counterLabel.removeFromParent()
            bubbleUpgradeTimer?.invalidate()
        }
    }
    
    func gameOver(){
        
        currentGameState = gameState.afterGame
        
        // stop everything
        self.removeAllActions()
        
        //stop bubblegun drops
        self.enumerateChildNodes(withName: "bubblegun", using: { bubbleGunNode, stop  in
                bubbleGunNode.removeAllActions()
            })
        
        //stop poop drops
        self.enumerateChildNodes(withName: "poop", using: { poopNode, stop  in
            poopNode.removeAllActions()
        })
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        
    }
    
    func changeScene(){
        
        let moveToScene = GameOverScene(size: self.size)
        moveToScene.scaleMode = self.scaleMode
        let transitionOfScreens = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(moveToScene, transition: transitionOfScreens)
    }
    
    //controls the contact between nodes of different cases
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // contact between scoop and poop
        if body1.categoryBitMask == PhysicsCategories.scoopCategory && body2.categoryBitMask == PhysicsCategories.poopCategory{
            
            addScore()
            body2.node?.removeFromParent()
            
        }
        
        //contact between firedBubble and poop
        if body1.categoryBitMask == PhysicsCategories.fireBubbleCategory && body2.categoryBitMask == PhysicsCategories.poopCategory{
            
            addScore()
            
            if body2.node != nil{
                bubbleExplosion(spawnBubbleExplosion: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        //contact between scoop and orangegundrop
        if body1.categoryBitMask == PhysicsCategories.scoopCategory && body2.categoryBitMask == PhysicsCategories.orangeBubbleDropCategory{
            
            print("orangegun crash")
            body2.node?.removeFromParent()
            scoop.run(SKAction.animate(with: [textureArray[1]], timePerFrame: 0))
            bubbleGunOn = true
            createCounter(colorOfGun: colorOfGun)
            sprayBubbles()
        }
        
        //contact between scoop and purplegundrop
        if body1.categoryBitMask == PhysicsCategories.scoopCategory && body2.categoryBitMask == PhysicsCategories.purpleBubbleDropCategory{
            
            print("purplegun crash")
            body2.node?.removeFromParent()
            scoop.run(SKAction.animate(with: [textureArray[2]], timePerFrame: 0))
            bubbleGunOn = true
            createCounter(colorOfGun: colorOfGun)
            sprayBubbles()
        }
    }
    
    func sprayBubbles(){
        
        let waitTimeOfBubbleShot = SKAction.wait(forDuration: 0.1)
        let autoShootBubbles = SKAction.run{
            self.fireBubble(bubbleGunOn: self.bubbleGunOn)
        }
        let autoShootSequence = SKAction.sequence([waitTimeOfBubbleShot,autoShootBubbles])
        scoop.run(SKAction.repeatForever(autoShootSequence))

    }
    
    //bubblegroup animation pops up when bubble collides with poop
    func bubbleExplosion(spawnBubbleExplosion: CGPoint){
        let bubbleExplosion = SKSpriteNode(imageNamed: "bubblegroup")
        bubbleExplosion.position = spawnBubbleExplosion
        bubbleExplosion.zPosition = 4
        bubbleExplosion.setScale(0)
        self.addChild(bubbleExplosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let bubbleExplosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        bubbleExplosion.run(bubbleExplosionSequence)
    }
    
    // increase spawn times after certain amount of points
    func changeDifficultyLevel(){
        
        difficultyLevel += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = CFTimeInterval()
        
        switch difficultyLevel{
        case 1: levelDuration = 0.6
        case 2: levelDuration = 0.4
        case 3: levelDuration = 0.4
        case 4: levelDuration = 0.3
        case 5: levelDuration = 0.2
            
        default:
            levelDuration = 0.2
            print("cannot find level info")
        }
        
        let spawn = SKAction.run(makePoop)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    //make it rain poops
    func makePoop(){
        
        let poop = SKSpriteNode(imageNamed: "poop")
        let randomX = random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: randomX, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomX, y: -self.size.height * 0.2)
        
        poop.name = "poop"
        poop.setScale(0.5)
        poop.position = startPoint
        poop.zPosition = 2
        poop.physicsBody = SKPhysicsBody(rectangleOf: poop.size)
        poop.physicsBody?.isDynamic = true
        
        poop.physicsBody?.categoryBitMask = PhysicsCategories.poopCategory
        poop.physicsBody?.contactTestBitMask = PhysicsCategories.scoopCategory | PhysicsCategories.fireBubbleCategory
        poop.physicsBody?.collisionBitMask = PhysicsCategories.None
        
        self.addChild(poop)
        
        if poop.position.x > gameArea.maxX - poop.size.width/2{
            poop.position.x = gameArea.maxX - poop.size.width/2
        }
        
        if poop.position.x < gameArea.minX + poop.size.width/2{
            poop.position.x = gameArea.minX + poop.size.width/2
        }
        
        let movePoop = SKAction.move(to: endPoint , duration: 3)
        let deletePoop = SKAction.removeFromParent()
        let lifeDecrease = SKAction.run(decreaseLives)
        let poopSequence = SKAction.sequence([movePoop, deletePoop, lifeDecrease])
        
        // the if statement is just incase poop spawns right when gameover occurs to avoid crash 
        if currentGameState == gameState.inGame{
            poop.run(poopSequence)
        }
        
    }
    
    //randomizes the spawns of orange and purple
    func startRandomSpawnBubbleGuns(){
        let randomChoiceOfGun = SKAction.run{
            self.colorOfGun = Int(self.randomInt(lower: 1, upper: 2))
            let gunSpawn = SKAction.run(self.bubbleGunUpgradeDrop)
            self.run(gunSpawn)
        }
        let randomSpawnTime = randomInt(lower: 3, upper: 5)
        let waitToSpawnGun = SKAction.wait(forDuration: TimeInterval(randomSpawnTime))
        let gunSpawnSeqeuence = SKAction.sequence([waitToSpawnGun, randomChoiceOfGun])
        let spawnGunForever = SKAction.repeatForever(gunSpawnSeqeuence)
        self.run(spawnGunForever)
    }

    
    //drops of upgrade bubblegun orange and purple
    func bubbleGunUpgradeDrop(){
        if ((bubbleGunOn == false) && (bubbleGunUpgradeDropOnScreen == false)){
            let randomX = random(min: gameArea.minX, max: gameArea.maxX)
            let startPoint = CGPoint(x: randomX, y: self.size.height * 1.2)
            let endPoint = CGPoint(x: randomX, y: -self.size.height * 0.2)
            let randomSpawnTime = randomInt(lower: 5, upper: 8)
            print(" colorOfGun:\(colorOfGun) randomspawntime:\(randomSpawnTime)")
            
            var bubbleGunDrop = SKSpriteNode()
            
            if colorOfGun == 1 {
                print("ran if statement 1")
                counterForBubbleGunUpgrade = 5
                bubbleGunDrop = SKSpriteNode(imageNamed: "bubblegunsideways")
                bubbleGunDrop.name = "bubblegun"
                bubbleGunDrop.physicsBody = SKPhysicsBody(rectangleOf: bubbleGunDrop.size)
                bubbleGunDrop.physicsBody?.isDynamic = true
                bubbleGunDrop.physicsBody?.categoryBitMask = PhysicsCategories.orangeBubbleDropCategory
                bubbleGunDrop.physicsBody?.contactTestBitMask = PhysicsCategories.scoopCategory
                bubbleGunDrop.physicsBody?.collisionBitMask = PhysicsCategories.None
                
            }else if colorOfGun == 2{
                print("ran if statement 2")
                counterForBubbleGunUpgrade = 10
                bubbleGunDrop = SKSpriteNode(imageNamed: "bubblemachinegun")
                bubbleGunDrop.name = "bubblegun"
                bubbleGunDrop.physicsBody = SKPhysicsBody(rectangleOf: bubbleGunDrop.size)
                bubbleGunDrop.physicsBody?.isDynamic = true
                bubbleGunDrop.physicsBody?.categoryBitMask = PhysicsCategories.purpleBubbleDropCategory
                bubbleGunDrop.physicsBody?.contactTestBitMask = PhysicsCategories.scoopCategory
                bubbleGunDrop.physicsBody?.collisionBitMask = PhysicsCategories.None
            }
            
            bubbleGunDrop.position = startPoint
            bubbleGunDrop.setScale(0.9)
            bubbleGunDrop.zPosition = 2

            
            self.addChild(bubbleGunDrop)
            
            if bubbleGunDrop.position.x > gameArea.maxX - bubbleGunDrop.size.width/2{
                bubbleGunDrop.position.x = gameArea.maxX - bubbleGunDrop.size.width/2
            }
            
            if bubbleGunDrop.position.x < gameArea.minX + bubbleGunDrop.size.width/2{
                bubbleGunDrop.position.x = gameArea.minX + bubbleGunDrop.size.width/2
            }
            let randomWaitDrop = SKAction.wait(forDuration: TimeInterval(randomSpawnTime))
            let moveBubbleDrop = SKAction.move(to: endPoint , duration: 3)
            let deleteBubbleDrop = SKAction.removeFromParent()
            let bubbleGunUpgradeIsCurrentlyOnScreen = SKAction.run(bubbleGunUpgradeIsOnScreen)
            let bubbleGunUpgradeIsNotCurrentlyOnScreen = SKAction.run(bubbleGunUpgradeIsNotOnScreen)
            let bubbleDropSequence = SKAction.sequence([bubbleGunUpgradeIsCurrentlyOnScreen,randomWaitDrop, moveBubbleDrop, deleteBubbleDrop, bubbleGunUpgradeIsNotCurrentlyOnScreen])
            if currentGameState == gameState.inGame{
                bubbleGunDrop.run(bubbleDropSequence)
                
            }
        }
    }
    
    func bubbleGunUpgradeIsOnScreen(){
        bubbleGunUpgradeDropOnScreen = true
    }
    
    func bubbleGunUpgradeIsNotOnScreen(){
        bubbleGunUpgradeDropOnScreen = false
    }
    
    
    //fire a bubble
    func fireBubble(bubbleGunOn: Bool){
        if bubbleGunOn == true {
            
            let bubbleNode = SKSpriteNode(imageNamed: "bubble")
            //lags when sound is added 
            //self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
            bubbleNode.name = "bubbleNode"
            bubbleNode.setScale(0.7)
            bubbleNode.position = scoop.position
            bubbleNode.position.y += 5
            
            bubbleNode.physicsBody = SKPhysicsBody(circleOfRadius: bubbleNode.size.width/2 )
            bubbleNode.physicsBody?.isDynamic = true
            
            bubbleNode.physicsBody?.categoryBitMask = PhysicsCategories.fireBubbleCategory
            bubbleNode.physicsBody?.contactTestBitMask = PhysicsCategories.poopCategory
            bubbleNode.physicsBody?.collisionBitMask = 0
            self.addChild(bubbleNode)
            
            let animationDuration: TimeInterval = 1
            
            let moveFiredBubble = SKAction.move(to: CGPoint(x: scoop.position.x, y: self.frame.height + 10), duration: animationDuration)
            let removeFiredBubble = SKAction.removeFromParent()
            let firingBubbleSequence = SKAction.sequence([moveFiredBubble, removeFiredBubble])
            bubbleNode.run(firingBubbleSequence)
        }
    }

}
