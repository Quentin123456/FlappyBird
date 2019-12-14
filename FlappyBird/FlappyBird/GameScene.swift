

import SpriteKit

enum coverage: CGFloat {
    case bkgground
    case barrier
    case frontBkg
    case gameRole
    case UI
}

enum gameState {
    case mainMenu
    case teaching
    case gaming
    case falling
    case showScore
    case ending
}

struct physics {
    static let nothing: UInt32 =        0
    static let gameRole: UInt32 = 0b1  // 1
    static let barrier: UInt32  = 0b10  // 2
    static let floor: UInt32   = 0b100  // 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let courseWeb = "http://baike.baidu.com/link?url=PvwsRaPdC-hNtpYhIMtMYh8dRCoRzPBCt93hqWRJiy0RcGmp5lBf3iIFCxyzjAHNqJOVNOicrgoOPCEs2OfGFGYJGz3solb6UV9PBgvWCOi#1"
    let AppStoreLink = "http://www.apple.com/cn/itunes/"
    
    let kFrontbkgCount = 2
    let kGrdMoveSpeed : CGFloat = -150.0
    let kGravity : CGFloat = -1500.0
    let kUpRushSpeed : CGFloat = 400.0
    let kMinMultiplier : CGFloat = 0.1
    let kMaxMultiplier : CGFloat = 0.6
    let kGapMultipliter : CGFloat = 3.5
    let kFirstDelay: NSTimeInterval = 1.75
    let kRepeatDelay: NSTimeInterval = 1.5
    let kAnimationDelay = 0.3
    let kTopSpace: CGFloat = 20.0
    let fontName = "AmericanTypewriter-Bold"
    let roleSumFrame = 4
    
    
    var scoreLabel: SKLabelNode!
    var currentScore = 0
    
    var 速度 = CGPoint.zero
    var hitGround = false
    var hitBarrier = false
    var currentGameState: gameState = .gaming
    
    let worldCanvas = SKNode()
    var gameZoneStartPoint: CGFloat = 0
    var gameZoneHeight: CGFloat = 0
    let mainActor = SKSpriteNode(imageNamed: "Bird0")
    let hat = SKSpriteNode(imageNamed: "Sombrero")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    //  创建音效
    let dings = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flappings = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let whacks = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let dropings = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hittings = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let pings = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        
        // 关掉重力
        physicsWorld.gravity = CGVectorMake(0, 0)
        // 设置碰撞代理
        physicsWorld.contactDelegate = self
        
        addChild(worldCanvas)
       shiftMainMenu()
    }
    
    // MARK: 设置的相关方法
    
    func setMainMenu() {
        
        // logo
        
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        logo.name = "mainMenu"
        logo.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(logo)
        
        // 开始游戏按钮
        
        let startGamingBtn = SKSpriteNode(imageNamed: "Button")
        startGamingBtn.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        startGamingBtn.name = "mainMenu"
        startGamingBtn.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(startGamingBtn)
        
        let gaming = SKSpriteNode(imageNamed: "Play")
        gaming.position = CGPoint.zero
        startGamingBtn.addChild(gaming)
        
        // 评价按钮
        
        let evalutionBtn = SKSpriteNode(imageNamed: "Button")
        evalutionBtn.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        evalutionBtn.zPosition = coverage.UI.rawValue
        evalutionBtn.name = "mainMenu"
        worldCanvas.addChild(evalutionBtn)
        
        let evalution = SKSpriteNode(imageNamed: "Rate")
        evalution.position = CGPoint.zero
        evalutionBtn.addChild(evalution)
        
        // 学习按钮
        
        let learning = SKSpriteNode(imageNamed: "button_learn")
        learning.position = CGPoint(x: size.width * 0.5, y: learning.size.height/2 + kTopSpace)
        learning.name = "mainMenu"
        learning.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(learning)
        
        // 学习按钮的动画
        let expandAmital = SKAction.scaleTo(1.02, duration: 0.75)
        expandAmital.timingMode = .EaseInEaseOut
        
        let miniAmital = SKAction.scaleTo(0.98, duration: 0.75)
        miniAmital.timingMode = .EaseInEaseOut
        
        learning.runAction(SKAction.repeatActionForever(SKAction.sequence([
            expandAmital,miniAmital
            ])), withKey: "mainMenu")
    }
    
    func setTeaching() {
        let teaching = SKSpriteNode(imageNamed: "Tutorial")
        teaching.position = CGPoint(x: size.width * 0.5 , y: gameZoneHeight * 0.4 + gameZoneStartPoint)
        teaching.name = "teaching"
        teaching.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(teaching)
        
        let ready = SKSpriteNode(imageNamed: "Ready")
        ready.position = CGPoint(x: size.width * 0.5, y: gameZoneHeight * 0.7 + gameZoneStartPoint)
        ready.name = "teaching"
        ready.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(ready)
        
        let upMove = SKAction.moveByX(0, y: 50, duration: 0.4)
        upMove.timingMode = .EaseInEaseOut
        let downMove = upMove.reversedAction()
        
        mainActor.runAction(SKAction.repeatActionForever(SKAction.sequence([
            upMove,downMove
            ])), withKey: "起飞")
        
        var actorArray: Array<SKTexture> = []
        
        for i in 0..<roleSumFrame {
            actorArray.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        
        for i in (roleSumFrame-1).stride(through: 0, by: -1) {//stride 是 Strideable 协议中定义的一个方法， 它可以按照指定的递进值生成一个序列
            actorArray.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        
        let winging = SKAction.animateWithTextures(actorArray, timePerFrame: 0.07)
        mainActor.runAction(SKAction.repeatActionForever(winging))
        
    }
    
    func setBackground() {
        let bkgground = SKSpriteNode(imageNamed: "Background")
        bkgground.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        bkgground.position = CGPoint(x: size.width/2, y: size.height)
        bkgground.zPosition = coverage.bkgground.rawValue
        worldCanvas.addChild(bkgground)
        
        gameZoneStartPoint = size.height - bkgground.size.height
        gameZoneHeight = bkgground.size.height
        
        let leftDown = CGPoint(x: 0, y: gameZoneStartPoint)
        let rightDown = CGPoint(x: size.width, y: gameZoneStartPoint)
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: leftDown, toPoint: rightDown)
        self.physicsBody?.categoryBitMask = physics.floor
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = physics.gameRole
        
    }
    
    func setMainActor() {
        mainActor.position = CGPoint(x: size.width * 0.2, y: gameZoneHeight * 0.4 + gameZoneStartPoint)
        mainActor.zPosition = coverage.gameRole.rawValue
        
        let offsetX = mainActor.size.width * mainActor.anchorPoint.x
        let offsetY = mainActor.size.height * mainActor.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 3 - offsetX, 12 - offsetY)
        CGPathAddLineToPoint(path, nil, 18 - offsetX, 22 - offsetY)
        CGPathAddLineToPoint(path, nil, 28 - offsetX, 27 - offsetY)
        CGPathAddLineToPoint(path, nil, 39 - offsetX, 23 - offsetY)
        CGPathAddLineToPoint(path, nil, 39 - offsetX, 9 - offsetY)
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 4 - offsetY)
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 2 - offsetY)
        
        CGPathCloseSubpath(path)
        
        mainActor.physicsBody = SKPhysicsBody(polygonFromPath: path)
        mainActor.physicsBody?.categoryBitMask = physics.gameRole
        mainActor.physicsBody?.collisionBitMask = 0
        mainActor.physicsBody?.contactTestBitMask = physics.barrier | physics.floor
        
        worldCanvas.addChild(mainActor)
    }
    
    func setFrontScene() {
        for i in 0..<kFrontbkgCount {
            let frontScone = SKSpriteNode(imageNamed: "Ground")
            frontScone.anchorPoint = CGPoint(x: 0, y: 1.0)
            frontScone.position = CGPoint(x: CGFloat(i) * frontScone.size.width, y: gameZoneStartPoint)
            frontScone.zPosition = coverage.frontBkg.rawValue
            frontScone.name = "前景"
            worldCanvas.addChild(frontScone)
        }
    }
    
    func setHat() {
        
        hat.position = CGPoint(x: 15 - hat.size.width/2, y: 29 - hat.size.height/2)
        mainActor.addChild(hat)
    }
    
    func setScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - kTopSpace)
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.text = "0"
        scoreLabel.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(scoreLabel)
    }
    
    func setScoreboard() {
        if currentScore > highestScore() {
            setHighestScore(currentScore)
        }
        
        let scorecard = SKSpriteNode(imageNamed: "ScoreCard")
        scorecard.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scorecard.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(scorecard)
        
        let currentScoreLabel = SKLabelNode(fontNamed: fontName)
        currentScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        currentScoreLabel.position = CGPoint(x: -scorecard.size.width / 4, y: -scorecard.size.height / 3)
        currentScoreLabel.text = "\(currentScore)"
        currentScoreLabel.zPosition = coverage.UI.rawValue
        scorecard.addChild(currentScoreLabel)
        
        let highestScoreLabel = SKLabelNode(fontNamed: fontName)
        highestScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        highestScoreLabel.position = CGPoint(x: scorecard.size.width / 4, y: -scorecard.size.height / 3)
        highestScoreLabel.text = "\(highestScore())"
        highestScoreLabel.zPosition = coverage.UI.rawValue
        scorecard.addChild(highestScoreLabel)
        
        let gamingending = SKSpriteNode(imageNamed: "GameOver")
        gamingending.position = CGPoint(x: size.width/2, y: size.height/2 + scorecard.size.height/2 + kTopSpace + gamingending.size.height/2)
        gamingending.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(gamingending)
        
        let okBtn = SKSpriteNode(imageNamed: "Button")
        okBtn.position = CGPoint(x: size.width/4, y: size.height/2 - scorecard.size.height/2 - kTopSpace - okBtn.size.height/2)
        okBtn.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(okBtn)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = coverage.UI.rawValue
        okBtn.addChild(ok)
        
        let shareBtn = SKSpriteNode(imageNamed: "ButtonRight")
        shareBtn.position = CGPoint(x: size.width * 0.75, y: size.height/2 - scorecard.size.height/2 - kTopSpace - shareBtn.size.height/2)
        shareBtn.zPosition = coverage.UI.rawValue
        worldCanvas.addChild(shareBtn)
        
        let share = SKSpriteNode(imageNamed: "Share")
        share.position = CGPoint.zero
        share.zPosition = coverage.UI.rawValue
        shareBtn.addChild(share)
        
        gamingending.setScale(0)
        gamingending.alpha = 0
        let animation = SKAction.group([
            SKAction.fadeInWithDuration(kAnimationDelay),
            SKAction.scaleTo(1.0, duration: kAnimationDelay)
            ])
        animation.timingMode = .EaseInEaseOut
        
        gamingending.runAction(SKAction.sequence([
            SKAction.waitForDuration(kAnimationDelay),
            animation
            ]))
        
        scorecard.position = CGPoint(x: size.width / 2, y: -scorecard.size.height/2)
        let upMoveAnimation = SKAction.moveTo(CGPoint(x: size.width / 2, y: size.height / 2), duration: kAnimationDelay)
        upMoveAnimation.timingMode = .EaseInEaseOut
        scorecard.runAction(SKAction.sequence([
            SKAction.waitForDuration(kAnimationDelay * 2),
            upMoveAnimation
            ]))
        
        okBtn.alpha = 0
        shareBtn.alpha = 0
        
        let changeAnimation = SKAction.sequence([
            SKAction.waitForDuration(kAnimationDelay * 3),
            SKAction.fadeInWithDuration(kAnimationDelay)
            ])
        okBtn.runAction(changeAnimation)
        shareBtn.runAction(changeAnimation)
        
        let sound = SKAction.sequence([
            SKAction.waitForDuration(kAnimationDelay),
            pings,
            SKAction.waitForDuration(kAnimationDelay),
            pings,
            SKAction.waitForDuration(kAnimationDelay),
            pings,
            SKAction.runBlock(shiftEndingState)
            ])
        
        runAction(sound)
    }
    
    
    // MARK: 游戏流程
    
    func createBarrier(imgName: String) -> SKSpriteNode {
        let barrier = SKSpriteNode(imageNamed: imgName)
        barrier.zPosition = coverage.barrier.rawValue
        barrier.userData = NSMutableDictionary()
        
        let offsetX = barrier.size.width * barrier.anchorPoint.x
        let offsetY = barrier.size.height * barrier.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 4 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 7 - offsetX, 307 - offsetY)
        CGPathAddLineToPoint(path, nil, 47 - offsetX, 308 - offsetY)
        CGPathAddLineToPoint(path, nil, 48 - offsetX, 1 - offsetY)
        
        CGPathCloseSubpath(path)
        
        barrier.physicsBody = SKPhysicsBody(polygonFromPath: path)
        barrier.physicsBody?.categoryBitMask = physics.barrier
        barrier.physicsBody?.collisionBitMask = 0
        barrier.physicsBody?.contactTestBitMask = physics.gameRole
        
        return barrier
    }
    
    func produceBarrier() {
        
        let bottomBarrier = createBarrier("CactusBottom")
        let startXpos = size.width + bottomBarrier.size.width/2
        
        let minY = (gameZoneStartPoint - bottomBarrier.size.height/2) + gameZoneHeight * kMinMultiplier
        let maxY = (gameZoneStartPoint - bottomBarrier.size.height/2) + gameZoneHeight * kMaxMultiplier
        bottomBarrier.position = CGPointMake(startXpos, CGFloat.random(min: minY, max: maxY))
        bottomBarrier.name = "底部障碍"
        worldCanvas.addChild(bottomBarrier)
        
        let topBarrier = createBarrier("CactusTop")
        topBarrier.zRotation = CGFloat(180).degreesToRadians()
        topBarrier.position = CGPoint(x: startXpos, y: bottomBarrier.position.y + bottomBarrier.size.height/2 + topBarrier.size.height/2 + mainActor.size.height * kGapMultipliter)
        topBarrier.name = "顶部障碍"
        worldCanvas.addChild(topBarrier)
        
        let XmoveDist = -(size.width + bottomBarrier.size.width)
        let moveDuration = XmoveDist / kGrdMoveSpeed
        
        let moveQueue = SKAction.sequence([
            SKAction.moveByX(XmoveDist, y: 0, duration: NSTimeInterval(moveDuration)),
            SKAction.removeFromParent()
            ])
        topBarrier.runAction(moveQueue)
        bottomBarrier.runAction(moveQueue)
        
    }
    
    func unlimitedCreatBarrier() {
        let fstDelay = SKAction.waitForDuration(kFirstDelay)
        let reBarrier = SKAction.runBlock(produceBarrier)
        let everyReBarrier = SKAction.waitForDuration(kRepeatDelay)
        let reBarrierQueue = SKAction.sequence([reBarrier, everyReBarrier])
        let unlimitedRebarr = SKAction.repeatActionForever(reBarrierQueue)
        let allQueue = SKAction.sequence([fstDelay, unlimitedRebarr])
        runAction(allQueue, withKey:"重生")
    }
    
    func stopReBarrier() {
        removeActionForKey("重生")
        
        worldCanvas.enumerateChildNodesWithName("顶部障碍", usingBlock: { matchNode, _ in
            matchNode.removeAllActions()
        })
        worldCanvas.enumerateChildNodesWithName("底部障碍", usingBlock: { matchNode, _ in
            matchNode.removeAllActions()
        })
        
    }
    
    
    func actorFlaying() {
        速度 = CGPoint(x: 0, y: kUpRushSpeed)
        
        // 移动帽子
        let upMove = SKAction.moveByX(0, y: 12, duration: 0.15)
        upMove.timingMode = .EaseInEaseOut
        let downMove = upMove.reversedAction()
        hat.runAction(SKAction.sequence([upMove, downMove]))
        
        // 播放音效
        runAction(flappings)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let click = touches.first else {
            return
        }
        let clickPos = click.locationInNode(self)
        
        switch currentGameState {
        case .mainMenu:
            if clickPos.y < size.height * 0.15 {
                goLearn()
            } else if clickPos.x < size.width/2 {
                shiftTeachingState()
            } else {
                goEvalution()
            }
            break
        case .teaching:
            shiftGamingState()
            break
        case .gaming:
            // 增加上冲速度
            actorFlaying()
            break
        case .falling:
            break
        case .showScore:
            break
        case .ending:
            shiftNewGame()
            break
        }
    }
    
    // MARK: 更新
    
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        switch currentGameState {
        case .mainMenu:
            break
        case .teaching:
            break
        case .gaming:
            updateFrontScene()
           updateMainActor()
            hitBarrierCheck()
            hitFloorCheck()
           updateScore()
            break
        case .falling:
           updateMainActor()
            hitFloorCheck()
            break
        case .showScore:
            break
        case .ending:
            break
        }
    }
    
    func updateMainActor() {
        let 加速度 = CGPoint(x: 0, y: kGravity)
        速度 = 速度 + 加速度 * CGFloat(dt)
        mainActor.position = mainActor.position + 速度 * CGFloat(dt)
        
        // 检测撞击floor时让其停在floor上
        if mainActor.position.y - mainActor.size.height/2 < gameZoneStartPoint {
            mainActor.position = CGPoint(x: mainActor.position.x, y: gameZoneStartPoint + mainActor.size.height/2)
        }
    }
    
    func updateFrontScene() {
        worldCanvas.enumerateChildNodesWithName("前景") { matchNode, _ in
            if let fscene = matchNode as? SKSpriteNode {
                let floorSpeed = CGPoint(x: self.kGrdMoveSpeed, y: 0)
                fscene.position += floorSpeed * CGFloat(self.dt)
                
                if fscene.position.x < -fscene.size.width {
                    fscene.position += CGPoint(x: fscene.size.width * CGFloat(self.kFrontbkgCount), y: 0)
                }
                
            }
        }
    }
    
    func hitBarrierCheck() {
        if hitBarrier {
            hitBarrier = false
            shiftFallingState()
        }
    }
    
    func hitFloorCheck() {
        if hitGround {
            hitGround = false
            速度 = CGPoint.zero
            mainActor.zRotation = CGFloat(-90).degreesToRadians()
            mainActor.position = CGPoint(x: mainActor.position.x, y: gameZoneStartPoint + mainActor.size.width/2)
            runAction(hittings)
            shiftShowScoreState()
        }
    }
    
    func updateScore() {
        worldCanvas.enumerateChildNodesWithName("顶部障碍", usingBlock: { matchNode, _ in
            if let barrier = matchNode as? SKSpriteNode {
                if let pass = barrier.userData?["已通过"] as? NSNumber {
                    if pass.boolValue {
                        return   // 已经计算过一次得分了
                    }
                }
                
                if self.mainActor.position.x > barrier.position.x + barrier.size.width/2 {
                    self.currentScore += 1
                    self.scoreLabel.text = "\(self.currentScore)"
                    self.runAction(self.coin)
                    barrier.userData?["已通过"] = NSNumber(bool: true)
                }
            }
        })
    }
    
    
    
    // MARK: gaming状态
    
    func shiftMainMenu() {
        
        currentGameState = .mainMenu
        setBackground()
        setFrontScene()
        setMainActor()
        setHat()
        setMainMenu()
        
    }
    
    func shiftTeachingState() {
        
        currentGameState = .teaching
        worldCanvas.enumerateChildNodesWithName("mainMenu") { matchNode, _ in
            matchNode.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.05),
                SKAction.removeFromParent()
                ]))
        }
        
        setScoreLabel()
        setTeaching()
        
    }
    
    func shiftGamingState() {
        
        currentGameState = .gaming
        
        worldCanvas.enumerateChildNodesWithName("teaching") { matchNode, _ in
            matchNode.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.05),
                SKAction.removeFromParent()
                ]))
        }
        mainActor.removeActionForKey("起飞")
        
        unlimitedCreatBarrier()
        actorFlaying()
        
    }
    
    func shiftFallingState() {
        
        currentGameState = .falling
        
        runAction(SKAction.sequence([
            whacks,
            SKAction.waitForDuration(0.1),
            dropings
            ]))
        
        mainActor.removeAllActions()
        stopReBarrier()
    }
    
    func shiftShowScoreState() {
        currentGameState = .showScore
        mainActor.removeAllActions()
        stopReBarrier()
        setScoreboard()
    }
    
    func shiftNewGame() {
        runAction(pings)
        
        let newScene = GameScene.init(size: size)
        let effect = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 0.05)
        view?.presentScene(newScene, transition: effect)
    }
    
    func shiftEndingState() {
        currentGameState = .ending
    }
    
    // MARK: 分数
    
    func highestScore() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("最高分")
    }
    
    func setHighestScore(highestScore: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(highestScore, forKey: "最高分")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: 物理引擎
    
    func didBeginContact(碰撞双方: SKPhysicsContact) {
        let 被撞对象 = 碰撞双方.bodyA.categoryBitMask ==
            physics.gameRole ? 碰撞双方.bodyB : 碰撞双方.bodyA
        
        if 被撞对象.categoryBitMask == physics.floor {
            hitGround = true
        }
        if 被撞对象.categoryBitMask == physics.barrier {
            hitBarrier = true
        }
    }
    
    // MARK: 其他
    
    func goLearn() {
        let website = NSURL(string: courseWeb)
        UIApplication.sharedApplication().openURL(website!)
    }
    
    func goEvalution() {
        let website = NSURL(string: AppStoreLink)
        UIApplication.sharedApplication().openURL(website!)
    }
    
}
