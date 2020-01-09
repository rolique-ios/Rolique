//
//  CashOwner.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/12/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

public enum CashOwner: String, CaseIterable {
  case officeManager = "Office Manager",
  hrManager = "Human Resource Manager"
  
  var apiName: String {
    switch self {
    case .officeManager:
      return "om"
    case .hrManager:
      return "hr"
    }
  }
  
  
  var types: [PaymentMethodType] { PaymentMethodType.allCases }
}


public enum PaymentMethodType: String, CaseIterable {
  case card,
  cash
  
  var image: UIImage {
    switch self {
    case .card:
      return R.image.card()!
    case .cash:
      return R.image.money()!
    }
  }
  
  init?(apiName: String) {
    switch apiName {
    case "Cash":
      self = .cash
    case "Credit card":
      self = .card
    default:
      return nil
    }
  }
}
