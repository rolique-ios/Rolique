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
}
