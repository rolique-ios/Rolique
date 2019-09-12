//
//  ConstraintsSettings.swift
//  GetGrub
//
//  Created by Bohdan Savych on 12/7/17.
//  Copyright © 2017 ROLIQUE. All rights reserved.
//

import UIKit

final public class ConstraintsSettings {
  fileprivate(set) var left: CGFloat?
  fileprivate(set) var right: CGFloat?
  fileprivate(set) var top: CGFloat?
  fileprivate(set) var bottom: CGFloat?
  fileprivate(set) var centerX: CGFloat?
  fileprivate(set) var centerY: CGFloat?
  fileprivate(set) var width: CGFloat?
  fileprivate(set) var height: CGFloat?
  
  public static var zero: ConstraintsSettings { return ConstraintsSettings(edgeInsets: .zero) }
  
  public init(left: CGFloat? = nil, right: CGFloat? = nil, top: CGFloat? = nil, bottom: CGFloat? = nil, centerX: CGFloat? = nil, centerY: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
    self.left = left
    self.right = right
    self.centerX = centerX
    self.centerY = centerY
    self.top = top
    self.bottom = bottom
    self.width = width
    self.height = height
  }
  
  public init(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
  }
  
  public init(edgeInsets: UIEdgeInsets = .zero) {
    self.left = edgeInsets.left
    self.right = edgeInsets.right
    self.top = edgeInsets.top
    self.bottom = edgeInsets.bottom
  }
  
  public init(centerX: CGFloat, centerY: CGFloat, width: CGFloat?, height: CGFloat?) {
    self.centerX = centerX
    self.centerY = centerY
    self.width = width
    self.height = height
  }
  
  public init(centerX: CGFloat, top: CGFloat?, bottom: CGFloat?, width: CGFloat?) {
    self.centerX = centerX
    self.top = top
    self.bottom = bottom
    self.width = width
  }
  
  public init(centerX: CGFloat, top: CGFloat?, left: CGFloat?, right: CGFloat?, height: CGFloat?) {
    self.centerX = centerX
    self.top = top
    self.left = left
    self.right = right
    self.height = height
  }
  
  public init(centerY: CGFloat, left: CGFloat?, right: CGFloat?, height: CGFloat?) {
    self.centerY = centerY
    self.left = left
    self.right = right
    self.height = height
  }
  
  public init(width: CGFloat?, height: CGFloat?, left: CGFloat?, right: CGFloat?, top: CGFloat?, bottom: CGFloat?) {
    //    assert(left == nil || right == nil || width == nil, "ambigious constraints")
    //    assert(top == nil || bottom == nil || height == nil, "ambigious constraints")
    
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
    self.width = width
    self.height = height
  }
}

extension UIView {
    typealias FormatFunction = (String) -> Void
    func getAddConstraintFunction(dict: [String: UIView]) -> FormatFunction {
        return { self.addVisualConstraint(format: $0, dict: dict) }
    }
    
    func addSubview(_ subview: UIView, with constraintsSettings: ConstraintsSettings) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        let dict = ["v": subview]
        let formats = [constraintsSettings.bottom
            .map { "V:[v]-" + "\($0)" + "-|" },
                       constraintsSettings.top
                        .map { "V:|-" + "\($0)" + "-[v]" },
                       constraintsSettings.right
                        .map { "H:[v]-" + "\($0)" + "-|" },
                       constraintsSettings.left
                        .map { "H:|-" + "\($0)" + "-[v]" }
        ]
        let addConstraintFunction = getAddConstraintFunction(dict: dict)
        formats.compactMap(This.id).forEach(addConstraintFunction)
        
        constraintsSettings.height.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .height,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.width.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .width,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.centerY.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerY,
                                             relatedBy: .equal, toItem: self, attribute: .centerY,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.centerX.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerX,
                                             relatedBy: .equal, toItem: self, attribute: .centerX,
                                             multiplier: 1, constant: $0))
        }
    }
    
    private func addVisualConstraint(format: String, dict: [String: UIView]) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: dict))
    }
}

