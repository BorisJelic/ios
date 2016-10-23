/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit

private let kAnimalNodeName = "movable"

class GameScene: SKScene {
  let background = SKSpriteNode(imageNamed: "blue-shooting-stars")
  var selectedNode = SKSpriteNode()

  override init(size: CGSize) {
    super.init(size: size)

    // 1
    self.background.name = "background"
    self.background.anchorPoint = CGPointZero
    self.addChild(background)

    // 2
    let imageNames = ["bird", "cat", "dog", "turtle"]

    for i in 0..<imageNames.count {
      let imageName = imageNames[i]

      let sprite = SKSpriteNode(imageNamed: imageName)
      sprite.name = kAnimalNodeName

      let offsetFraction = (CGFloat(i) + 1.0)/(CGFloat(imageNames.count) + 1.0)

      sprite.position = CGPoint(x: size.width * offsetFraction, y: size.height / 2)

      background.addChild(sprite)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

//  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    let touch = touches.anyObject() as UITouch
//    let positionInScene = touch.locationInNode(self)
//
//    selectNodeForTouch(positionInScene)
//  }
//
//  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
//    let touch = touches.anyObject() as UITouch
//    let positionInScene = touch.locationInNode(self)
//    let previousPosition = touch.previousLocationInNode(self)
//    let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
//
//    panForTranslation(translation)
//  }

  override func didMoveToView(view: SKView) {
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
    self.view!.addGestureRecognizer(gestureRecognizer)
  }

  func handlePanFrom(recognizer : UIPanGestureRecognizer) {
    if recognizer.state == .Began {
      var touchLocation = recognizer.locationInView(recognizer.view)
      touchLocation = self.convertPointFromView(touchLocation)

      self.selectNodeForTouch(touchLocation)
    } else if recognizer.state == .Changed {
      var translation = recognizer.translationInView(recognizer.view!)
      translation = CGPoint(x: translation.x, y: -translation.y)

      self.panForTranslation(translation)

      recognizer.setTranslation(CGPointZero, inView: recognizer.view)
    } else if recognizer.state == .Ended {
      if selectedNode.name != kAnimalNodeName {
        let scrollDuration = 0.2
        let velocity = recognizer.velocityInView(recognizer.view)
        let pos = selectedNode.position

        // This just multiplies your velocity with the scroll duration.
        let p = CGPoint(x: velocity.x * CGFloat(scrollDuration), y: velocity.y * CGFloat(scrollDuration))

        var newPos = CGPoint(x: pos.x + p.x, y: pos.y + p.y)
        newPos = self.boundLayerPos(newPos)
        selectedNode.removeAllActions()

        let moveTo = SKAction.moveTo(newPos, duration: scrollDuration)
        moveTo.timingMode = .EaseOut
        selectedNode.runAction(moveTo)
      }
    }
  }

  func degToRad(degree: Double) -> CGFloat {
    return CGFloat(degree / 180.0 * M_PI)
  }

  func selectNodeForTouch(touchLocation : CGPoint) {
    // 1
    let touchedNode = self.nodeAtPoint(touchLocation)

    if touchedNode is SKSpriteNode {
      // 2
      if !selectedNode.isEqual(touchedNode) {
        selectedNode.removeAllActions()
        selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))

        selectedNode = touchedNode as! SKSpriteNode

        // 3
        if touchedNode.name! == kAnimalNodeName {
          let sequence = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),
            SKAction.rotateByAngle(0.0, duration: 0.1),
            SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
          selectedNode.runAction(SKAction.repeatActionForever(sequence))
        }
      }
    }
  }

  func boundLayerPos(aNewPosition : CGPoint) -> CGPoint {
    let winSize = self.size
    var retval = aNewPosition
    retval.x = CGFloat(min(retval.x, 0))
    retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
    retval.y = self.position.y

    return retval
  }

  func panForTranslation(translation : CGPoint) {
    let position = selectedNode.position

    if selectedNode.name! == kAnimalNodeName {
      selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
    } else {
      let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
      background.position = self.boundLayerPos(aNewPosition)
    }
  }

}
