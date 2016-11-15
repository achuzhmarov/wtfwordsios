//
//  GameController.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import UIKit

class GameController {
  var gameView: UIView!
  var message: Message!
  
  private var tiles = [TileView]()
  fileprivate var targets = [TargetView]()

  /*var hud:HUDView! {
    didSet {
      //connect the Hint button
      hud.hintButton.addTarget(self, action: #selector(GameController.actionHint), for:.touchUpInside)
      hud.hintButton.isEnabled = false
    }
  }*/
  
  //stopwatch variables
  private var secondsLeft: Int = 0
  private var timer: Timer?

  private var data = GameData()

  fileprivate var audioController: AudioController
  
  var onAnagramSolved:( () -> ())!
  
  init() {
    self.audioController = AudioController()
    self.audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
  }
  
  func dealRandomAnagram () {
    let wordText = message.words[0].text
    let wordlength = CGFloat(wordText.characters.count)
    print("word[\(wordlength)]: \(wordText)")

    let screenWidth = gameView.bounds.size.width

    //calculate the tile size
    let tileSide = min(ceil(screenWidth * 0.9 / wordlength) - TileMargin, TileMaxSide)

    //get the left margin for first tile
    var xOffset = (screenWidth - wordlength * (tileSide + TileMargin)) / 2.0
    
    //adjust for tile center (instead of the tile's origin)
    xOffset += tileSide / 2.0
    
    //initialize target list
    targets = []
    
    //create targets
    var index = 0
    for letter in wordText.characters {
        let target = TargetView(letter: letter, sideLength: tileSide)

        target.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin), y: tileSide / 2 + 8)

        gameView.addSubview(target)
        targets.append(target)
        
        index += 1
    }
    
    //1 initialize tile list
    tiles = []
    
    //2 create tiles
    index = 0
    for letter in wordText.characters {
        //3
        let tile = TileView(letter: letter, sideLength: tileSide)
        tile.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin),
                              y: tileSide * 2)

        tile.randomize()
        tile.dragDelegate = self

        //4
        gameView.addSubview(tile)
        tiles.append(tile)
        
        index += 1
    }

    //hud.hintButton.isEnabled = true
  }
  
  func placeTile(_ tileView: TileView, targetView: TargetView) {
    //1
    targetView.isMatched = true
    tileView.isMatched = true
    
    //2
    tileView.isUserInteractionEnabled = false
    
    //3
    UIView.animate(withDuration: 0.35,
      delay:0.00,
      options:UIViewAnimationOptions.curveEaseOut,
      //4
      animations: {
        tileView.center = targetView.center
        tileView.transform = CGAffineTransform.identity
      },
      //5
      completion: {
        (value:Bool) in
        targetView.isHidden = true
    })
    
    let explode = ExplodeView(frame:CGRect(x: tileView.center.x, y: tileView.center.y, width: 10,height: 10))
    tileView.superview?.addSubview(explode)
    tileView.superview?.sendSubview(toBack: explode)
  }
  
  
  
  func checkForSuccess() {
    for targetView in targets {
      //no success, bail out
      if !targetView.isMatched {
        return
      }
    }
    print("Game Over!")
    
    //hud.hintButton.isEnabled = false

    //the anagram is completed!
    audioController.playEffect(SoundWin)
    
    // win animation
    let firstTarget = targets[0]
    let startX:CGFloat = 0

    let endX:CGFloat = gameView.bounds.size.width + 300
    let startY = firstTarget.center.y
    
    let stars = StardustView(frame: CGRect(x: startX, y: startY, width: 10, height: 10))
    gameView.addSubview(stars)
    gameView.sendSubview(toBack: stars)
    
    UIView.animate(withDuration: 3.0,
      delay:0.0,
      options:UIViewAnimationOptions.curveEaseOut,
      animations:{
        stars.center = CGPoint(x: endX, y: startY)
      }, completion: {(value:Bool) in
        //game finished
        stars.removeFromSuperview()

        //when animation is finished, show menu
        self.clearBoard()
        self.onAnagramSolved()
    })
  }
  
  //the user pressed the hint button
  @objc func actionHint() {
    //1
    //hud.hintButton.isEnabled = false
    
    //2
    //data.points -= level.pointsPerTile / 2
    //hud.gamePoints.setValue(data.points, duration: 1.5)
    
    //3 find the first unmatched target and matching tile
    var foundTarget:TargetView? = nil
    for target in targets {
      if !target.isMatched {
        foundTarget = target
        break
      }
    }
    
    //4 find the first tile matching the target
    var foundTile:TileView? = nil
    for tile in tiles {
      if !tile.isMatched && tile.letter == foundTarget?.letter {
        foundTile = tile
        break
      }
    }
    
    //ensure there is a matching tile and target
    if let target = foundTarget, let tile = foundTile {
      
      //5 don't want the tile sliding under other tiles
      gameView.bringSubview(toFront: tile)
      
      //6 show the animation to the user
      UIView.animate(withDuration: 1.5,
        delay:0.0,
        options:UIViewAnimationOptions.curveEaseOut,
        animations:{
          tile.center = target.center
        }, completion: {
          (value:Bool) in
          
          //7 adjust view on spot
          self.placeTile(tile, targetView: target)
          
          //8 re-enable the button
          //self.hud.hintButton.isEnabled = true
          
          //9 check for finished game
          self.checkForSuccess()
          
      })
    }
  }
  
  //clear the tiles and targets
  func clearBoard() {
    tiles.removeAll(keepingCapacity: false)
    targets.removeAll(keepingCapacity: false)
    
    for view in gameView.subviews  {
      view.removeFromSuperview()
    }
  }
  
}

extension GameController:TileDragDelegateProtocol {
  //a tile was dragged, check if matches a target
  func tileView(_ tileView: TileView, didDragToPoint point: CGPoint) {
    var targetView: TargetView?
    for tv in targets {
      if tv.frame.contains(point) && !tv.isMatched {
        targetView = tv
        break
      }
    }
    
    //1 check if target was found
    if let targetView = targetView {
      
      //2 check if letter matches
      if targetView.letter == tileView.letter {
        
        //3
        self.placeTile(tileView, targetView: targetView)

        //more stuff to do on success here
        
        audioController.playEffect(SoundDing)
        
        //give points
        //data.points += level.pointsPerTile
        //hud.gamePoints.setValue(data.points, duration: 0.5)
        
        //check for finished game
        self.checkForSuccess()
      
      } else {
        
        //4
        //1
        tileView.randomize()
        
        //2
        UIView.animate(withDuration: 0.35,
          delay:0.00,
          options:UIViewAnimationOptions.curveEaseOut,
          animations: {
            tileView.center = CGPoint(x: tileView.center.x + CGFloat(randomNumber(minX:0, maxX:40)-20),
              y: tileView.center.y + CGFloat(randomNumber(minX:20, maxX:30)))
          },
          completion: nil)
        
        //more stuff to do on failure here
        
        audioController.playEffect(SoundWrong)
        
        //take out points
        //data.points -= level.pointsPerTile/2
        //hud.gamePoints.setValue(data.points, duration: 0.25)
      }
    }
    
  }
  

}
