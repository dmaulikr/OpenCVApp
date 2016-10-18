//
//  ARView.swift
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/17/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import Foundation

class ARView : UIView {
    let kDRAW_TARGET_DRAW_RINGS  =  1
    let kDRAW_TARGET_BULLET_HOLES = 1
    let kColorBackground = UIColor.darkGray
    let kColorBulletHole = UIColor.green
    let kColorRing1 = UIColor.blue
    let kColorRing2 = UIColor.green
    let kColorRing3 = UIColor.yellow
    let kColorRing4 = UIColor.orange
    let kColorRing5 = UIColor.red

    let kRadius5 = 18.0
    let kRadius4 = 30.0
    let kRadius3 = 45.0
    let kRadius2 = 58.0
    let kRadius1 = 73.0
    
    let kAlphaShow = 0.5
    let kAlphaHide = 0.0
    var centerPoint:CGPoint = CGPoint(x:0, y:0)
    var ringNumber:Int = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        centerPoint = CGPoint(x:frame.width/2.0, y:frame.height/2.0)
        self.backgroundColor = kColorBackground
        self.ringNumber = 1
    }
    
    override func draw(_ rect: CGRect) {
        switch ( self.ringNumber ) {
        case 1:
            drawTargetCircle(center: self.center, color: kColorRing1, radius: CGFloat(kRadius1))
            break;
        case 2:
            drawTargetCircle(center: self.center, color: kColorRing2, radius: CGFloat(kRadius2))
            break;
        case 3:
            drawTargetCircle(center: self.center, color: kColorRing3, radius: CGFloat(kRadius3))
            break;
        case 4:
            drawTargetCircle(center: self.center, color: kColorRing4, radius: CGFloat(kRadius4))
            break;
        case 5:
            drawTargetCircle(center: self.center, color: kColorRing5, radius: CGFloat(kRadius5))
            break;
        default:
            break
        }

    }
    
    func selectBestRing(point:CGPoint) -> Int {
        var bestRing = 0
        let dist = distance(a: point, b: centerPoint)
        if ( dist < kRadius5 )      { bestRing = 5; }
        else if ( dist < kRadius4 ) { bestRing = 4; }
        else if ( dist < kRadius3 ) { bestRing = 3; }
        else if ( dist < kRadius2 ) { bestRing = 2; }
        else if ( dist < kRadius1 ) { bestRing = 1; }
        return bestRing
    }
    
    func show() {
        self.alpha = CGFloat(kAlphaShow)
    }
    
    func hide() {
        self.alpha = CGFloat(kAlphaHide)
    }
    
    private func distance(a:CGPoint, b:CGPoint) -> Double {
        let dx = Double(b.x - a.x)
        let dy = Double(b.y - a.y)
        
        return sqrt(dx * dx + dy * dy)
    }
    
    private func drawTargetCircle(center:CGPoint, color:UIColor, radius:CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        let circle1 = CGRect(x:center.x - radius, y:center.y - radius, width:radius, height:radius)
        context!.fillEllipse(in: circle1)
        
    }
}
