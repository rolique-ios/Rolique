//
//  ActivityIndicator.swift
//  Utils
//
//  Created by Maksym Ivanyk on 9/12/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
final public class ActivityIndicator: UIView {
  var animationDuration = 1.0
  var rotationDuration = 10.0
  
  @IBInspectable
  var numSegments: Int = 12 {
    didSet {
      updateSegments()
    }
  }
  
  @IBInspectable
  var strokeColor: UIColor = .blue {
    didSet {
      segmentLayer?.strokeColor = strokeColor.cgColor
    }
  }
  
  @IBInspectable
  var lineWidth: CGFloat = 8 {
    didSet {
      segmentLayer?.lineWidth = lineWidth
      updateSegments()
    }
  }
  
  var hidesWhenStopped: Bool = true
  fileprivate(set) var isAnimating = false
  fileprivate weak var replicatorLayer: CAReplicatorLayer!
  fileprivate weak var segmentLayer: CAShapeLayer!
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setup()
  }
  
  private func setup() {
    let replicatorLayer = CAReplicatorLayer()
    layer.addSublayer(replicatorLayer)
    
    let dot = CAShapeLayer()
    dot.lineCap = CAShapeLayerLineCap.round
    dot.strokeColor = strokeColor.cgColor
    dot.lineWidth = lineWidth
    dot.fillColor = nil
    
    replicatorLayer.addSublayer(dot)
    
    self.replicatorLayer = replicatorLayer
    self.segmentLayer = dot
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    let maxSize = max(0, min(bounds.width, bounds.height))
    replicatorLayer.bounds = CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
    replicatorLayer.position = CGPoint(x: bounds.width/2, y:bounds.height/2)
    
    updateSegments()
  }
  
  private func updateSegments() {
    guard numSegments > 0, let segmentLayer = segmentLayer else { return }
    
    let angle = 2 * CGFloat.pi / CGFloat(numSegments)
    replicatorLayer.instanceCount = numSegments
    replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
    replicatorLayer.instanceDelay = 1.5 * animationDuration / Double(numSegments)
    
    let maxRadius = max(0, min(replicatorLayer.bounds.width, replicatorLayer.bounds.height))/2
    let radius: CGFloat = maxRadius - lineWidth/2
    
    segmentLayer.bounds = CGRect(x:0, y:0, width: 2 * maxRadius, height: 2 * maxRadius)
    segmentLayer.position = CGPoint(x: replicatorLayer.bounds.width / 2, y: replicatorLayer.bounds.height / 2)
    
    let path = UIBezierPath(arcCenter: CGPoint(x: maxRadius, y: maxRadius), radius: radius, startAngle: -angle / 2 - CGFloat.pi / 2, endAngle: angle / 2 - CGFloat.pi / 2, clockwise: true)
    
    segmentLayer.path = path.cgPath
  }
  
  public func startAnimating() {
    self.isHidden = false
    isAnimating = true
    
    let rotate = CABasicAnimation(keyPath: "transform.rotation")
    rotate.byValue = CGFloat.pi*2
    rotate.duration = rotationDuration
    rotate.repeatCount = Float.infinity
    
    let shrinkStart = CABasicAnimation(keyPath: "strokeStart")
    shrinkStart.fromValue = 0.0
    shrinkStart.toValue = 0.5
    shrinkStart.duration = animationDuration
    shrinkStart.autoreverses = true
    shrinkStart.repeatCount = Float.infinity
    shrinkStart.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    let shrinkEnd = CABasicAnimation(keyPath: "strokeEnd")
    shrinkEnd.fromValue = 1.0
    shrinkEnd.toValue = 0.5
    shrinkEnd.duration = animationDuration
    shrinkEnd.autoreverses = true
    shrinkEnd.repeatCount = Float.infinity
    shrinkEnd.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    let fade = CABasicAnimation(keyPath: "lineWidth")
    fade.fromValue = lineWidth
    fade.toValue = 0.0
    fade.duration = animationDuration
    fade.autoreverses = true
    fade.repeatCount = Float.infinity
    fade.timingFunction = CAMediaTimingFunction(controlPoints: 0.55, 0.0, 0.45, 1.0)
    
    replicatorLayer.add(rotate, forKey: "rotate")
    segmentLayer.add(shrinkStart, forKey: "start")
    segmentLayer.add(shrinkEnd, forKey: "end")
    segmentLayer.add(fade, forKey: "fade")
  }
  
  public func stopAnimating() {
    isAnimating = false
    
    replicatorLayer.removeAnimation(forKey: "rotate")
    segmentLayer.removeAnimation(forKey: "start")
    segmentLayer.removeAnimation(forKey: "end")
    segmentLayer.removeAnimation(forKey: "fade")
    
    if hidesWhenStopped {
      self.isHidden = true
    }
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 180, height: 180)
  }
}
