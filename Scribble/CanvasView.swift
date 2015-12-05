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
  private let ForceSensitivity:CGFloat = 4.0
  private let TiltThreshold = π/6  // 30º
  private let MinLineWidth:CGFloat = 5
  
  private var drawingImage: UIImage?
  
  private var drawColor: UIColor = UIColor.redColor()
  private var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)
  
  private var eraserColor: UIColor {
    if let backgroundColor = self.backgroundColor {
      return backgroundColor
    }
    return UIColor.whiteColor()
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    // Draw previous image into context
    drawingImage?.drawInRect(bounds)
    
    // 1
    var touches = [UITouch]()
    
    // Coalesce Touches
    // 2
    if let coalescedTouches = event?.coalescedTouchesForTouch(touch) {
      touches = coalescedTouches
    } else {
      touches.append(touch)
    }
    
    // 4
    for touch in touches {
      drawStroke(context, touch: touch)
    }
    
    // 1
    drawingImage = UIGraphicsGetImageFromCurrentImageContext()
    // 2
    if let predictedTouches = event?.predictedTouchesForTouch(touch) {
      for touch in predictedTouches {
        drawStroke(context, touch: touch)
      }
    }
    
    // Update image
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  override func touchesEnded(touches: Set<UITouch>,
    withEvent event: UIEvent?) {
      self.image = drawingImage
  }
  
  override func touchesCancelled(touches: Set<UITouch>?,
    withEvent event: UIEvent?) {
      self.image = drawingImage
  }
  
  private func drawStroke(context: CGContext?, touch: UITouch) {
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    var lineWidth:CGFloat
    if touch.type == .Stylus {
      // Calculate line width for drawing stroke
      if touch.altitudeAngle < TiltThreshold {
        lineWidth = lineWidthForShading(context, touch: touch)
      } else {
        lineWidth = lineWidthForDrawing(context, touch: touch)
      }
      // Set color
      pencilTexture.setStroke()
    } else {
      // Erase with finger
      lineWidth = touch.majorRadius / 2
      eraserColor.setStroke()
    }
    
    // Configure line
    CGContextSetLineWidth(context, lineWidth)
    CGContextSetLineCap(context, .Round)

    
    // Set up the points
    CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
    CGContextAddLineToPoint(context, location.x, location.y)
    // Draw the stroke
    CGContextStrokePath(context)
    
  }
  
  private func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {
    
    // 1
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    // 2 - vector1 is the pencil direction
    let vector1 = touch.azimuthUnitVectorInView(self)
    
    // 3 - vector2 is the stroke direction
    let vector2 = CGPoint(x: location.x - previousLocation.x,
      y: location.y - previousLocation.y)
    
    // 4 - Angle difference between the two vectors
    var angle = abs(atan2(vector2.y, vector2.x)
      - atan2(vector1.dy, vector1.dx))
    
    // 5
    if angle > π {
      angle = 2 * π - angle
    }
    if angle > π / 2 {
      angle = π - angle
    }
    
    // 6
    let minAngle:CGFloat = 0
    let maxAngle:CGFloat = π / 2
    let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)
    
    // 7
    let maxLineWidth:CGFloat = 60
    var lineWidth:CGFloat
    lineWidth = maxLineWidth * normalizedAngle
    
    // 1 - modify lineWidth by altitude (tilt of the Pencil)
    // 0.25 radians means widest stroke and TiltThreshold is where shading narrows to line.
    
    let minAltitudeAngle:CGFloat = 0.25
    let maxAltitudeAngle:CGFloat = TiltThreshold
    
    // 2
    let altitudeAngle = touch.altitudeAngle < minAltitudeAngle
      ? minAltitudeAngle : touch.altitudeAngle
    
    // 3 - normalize between 0 and 1
    let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle)
      / (maxAltitudeAngle - minAltitudeAngle))
    // 4
    lineWidth = lineWidth * normalizedAltitude + MinLineWidth
    
    // Set alpha of shading using force
    let minForce:CGFloat = 0.0
    let maxForce:CGFloat = 5
    
    // Normalize between 0 and 1
    let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
    
    CGContextSetAlpha(context, normalizedAlpha)
    
    return lineWidth
  }
  
  
  private func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {

    var lineWidth:CGFloat
    lineWidth = DefaultLineWidth
    
    if touch.force > 0 {  // If finger, touch.force = 0
      lineWidth = touch.force * ForceSensitivity
    }
    
    return lineWidth
  }
  
  func clearCanvas(animated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.5, animations: {
        self.alpha = 0
        }, completion: { finished in
          self.alpha = 1
          self.image = nil
          self.drawingImage = nil
      })
    } else {
      self.image = nil
      self.drawingImage = nil
    }
  }
}
