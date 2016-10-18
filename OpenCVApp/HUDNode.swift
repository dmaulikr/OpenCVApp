//
//  HUDNode.swift
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/16/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import Foundation

import SpriteKit
import GameController


class HUDNode : SKNode {
    var size = CGSize.zero
    var overlay:SKScene?
    var healthBar:SKSpriteNode?
    let maxHealth = 100
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(scene:SKScene, size:CGSize) {
        super.init()
        self.size = size
        self.overlay = scene
        
        self.addControls()
    }
    
    func setHealth(value:Int) {
        updateHealthBar(node: healthBar!, withHealthPoints: value)
    }
    
    private func addControls() {
        
        let dpadSprite = SKSpriteNode(imageNamed: "art.scnassets/images/crosshairs")
        dpadSprite.position = CGPoint(x:size.width * 0.5, y:size.height*0.5)
        dpadSprite.name = "dpad"
        dpadSprite.zPosition = 1.0
        self.addChild(dpadSprite)
            
        let attackSprite = SKSpriteNode(imageNamed: "art.scnassets/images/close@2x")
        attackSprite.position = CGPoint(x:size.width * 0.85, y:size.height*0.2)
        attackSprite.name = "attackNode"
        attackSprite.zPosition = 1.0
        self.addChild(attackSprite)
        
        let position = CGPoint(x:size.width * 0.1, y:size.height*0.9)
        self.healthBar = self.createHealthBar(position: position)
        self.setHealth(value: 40)
    }
    
    func removeControls() {
        healthBar!.isHidden = true
    }

    private func createHealthBar(position:CGPoint) -> SKSpriteNode {
        let playerHealthBar = SKSpriteNode()
        
        addChild(playerHealthBar)
        
        playerHealthBar.position = CGPoint(x: position.x, y: position.y)
        return playerHealthBar
    }
    
    private func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        let HealthBarWidth: CGFloat = 40
        let HealthBarHeight: CGFloat = 10
        let barSize = CGSize(width: HealthBarWidth, height: HealthBarHeight);
        
        let fillColor = SKColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = SKColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
        context!.stroke(borderRect, width: 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(maxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize
    }


}
