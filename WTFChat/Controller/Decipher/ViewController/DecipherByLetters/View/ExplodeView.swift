//
//  ExplodeView.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import UIKit

class ExplodeView: UIView {
  //1
  fileprivate var emitter:CAEmitterLayer!
  
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(frame:")
  }
  
  override init(frame:CGRect) {
    super.init(frame:frame)
    
    //initialize the emitter
    emitter = self.layer as! CAEmitterLayer
    emitter.emitterPosition = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    emitter.emitterSize = self.bounds.size
    emitter.emitterMode = kCAEmitterLayerAdditive
    emitter.emitterShape = kCAEmitterLayerRectangle
  }
  
  //2 configure the UIView to have an emitter layer
  override class var layerClass : AnyClass {
    return CAEmitterLayer.self
  }
  
  override func didMoveToSuperview() {
    //1
    super.didMoveToSuperview()
    if self.superview == nil {
      return
    }
    
    //2
    let texture:UIImage? = UIImage(named:"particle")
    assert(texture != nil, "particle image not found")
    
    //3
    let emitterCell = CAEmitterCell()
    
    //4
    emitterCell.contents = texture!.cgImage
    
    //5
    emitterCell.name = "cell"
    
    //6
    emitterCell.birthRate = 1000
    emitterCell.lifetime = 0.75
    
    //7
    emitterCell.blueRange = 0.33
    emitterCell.blueSpeed = -0.33
    
    //8
    emitterCell.velocity = 160
    emitterCell.velocityRange = 40
    
    //9
    emitterCell.scaleRange = 0.5
    emitterCell.scaleSpeed = -0.2
    
    //10
    emitterCell.emissionRange = CGFloat(M_PI*2)
    
    //11
    emitter.emitterCells = [emitterCell]
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.disableEmitterCell()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.removeFromSuperview()
    }
  }
  
  func disableEmitterCell() {
    emitter.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
  }
  
}
