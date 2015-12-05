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

import UIKit

let π = CGFloat(M_PI)

class CanvasView: UIImageView {
  
  // Parameters
  private let DefaultLineWidth:CGFloat = 6
  
  private var drawColor: UIColor = UIColor.redColor()
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    // Draw previous image into context
    self.image?.drawInRect(bounds)
    
    drawStroke(context, touch: touch)
    
    // Update image
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  private func drawStroke(context: CGContext?, touch: UITouch) {
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    // Calculate line width for drawing stroke
    let lineWidth = lineWidthForDrawing(context, touch: touch)

    // Set color
    drawColor.setStroke()

    // Configure line
    CGContextSetLineWidth(context, lineWidth)
    CGContextSetLineCap(context, .Round)

    
    // Set up the points
    CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
    CGContextAddLineToPoint(context, location.x, location.y)
    // Draw the stroke
    CGContextStrokePath(context)
    
  }
  
  private func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {

    var lineWidth:CGFloat
    lineWidth = DefaultLineWidth
    
    return lineWidth
  }
  
  func clearCanvas(animated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.5, animations: {
        self.alpha = 0
        }, completion: { finished in
          self.alpha = 1
          self.image = nil
      })
    } else {
      self.image = nil
    }
  }
}
