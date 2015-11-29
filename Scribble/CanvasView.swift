//
//  CanvasView.swift
//  Scribble
//
//  Created by Caroline Begbie on 29/11/2015.
//  Copyright © 2015 Caroline Begbie. All rights reserved.
//

import UIKit

@IBDesignable
class CanvasView: UIImageView {
  
  var drawingImage: UIImage?
  
  @IBInspectable var drawColor: UIColor = UIColor.redColor()
  @IBInspectable var lineWidth: CGFloat = 6

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.borderColor = UIColor.blueColor().CGColor
    self.layer.borderWidth = 1
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    // Draw previous image into context
    self.image?.drawInRect(bounds)
    
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    // Set up the stroke
    CGContextSetLineCap(context, .Round)
    CGContextSetLineWidth(context, lineWidth)
    drawColor.setStroke()

    // Set up the points
    CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
    CGContextAddLineToPoint(context, location.x, location.y)
    
    // Draw the stroke
    CGContextStrokePath(context)
    
    // Update image
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
  }
  
  func drawStroke(fromPoint: CGPoint, toPoint: CGPoint) {
    
  }
}
