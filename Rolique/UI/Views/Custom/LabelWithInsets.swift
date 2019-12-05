//
//  LabelWithInsets.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class LabelWithInsets: UILabel {
  var insets = UIEdgeInsets()
  
  convenience init(insets: UIEdgeInsets) {
    self.init(frame: .zero)
    self.insets = insets
  }
  
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: insets))
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var adjSize = super.sizeThatFits(size)
    adjSize.width += insets.left + insets.right
    adjSize.height += insets.top + insets.bottom
    
    return adjSize
  }
  
  override var intrinsicContentSize: CGSize {
    var contentSize = super.intrinsicContentSize
    contentSize.width += insets.left + insets.right
    contentSize.height += insets.top + insets.bottom
    
    return contentSize
  }
}
