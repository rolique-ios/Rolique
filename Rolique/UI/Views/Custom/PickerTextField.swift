//
//  PickerTextField.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {
  let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override func caretRect(for position: UITextPosition) -> CGRect {
    return CGRect.zero
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    switch action {
    case #selector(copy(_:)), #selector(selectAll(_:)), #selector(paste(_:)):
      return false
    default:
      return super.canPerformAction(action, withSender: sender)
    }
  }
}
