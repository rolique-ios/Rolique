//
//  CancelButton.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/28/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class CancelButton: UIButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    setTitle(Strings.Actions.cancel, for: .normal)
    setTitleColor(UIColor.red, for: .normal)
    layer.cornerRadius = 5.0
    layer.borderWidth = 2.0
    layer.borderColor = UIColor.red.cgColor
  }
}
