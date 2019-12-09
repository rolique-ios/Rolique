//
//  Expense.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/9/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

final class Expense {
  let value: Double
  let date: Date?
  let description: String?
  
  init(value: Double, date: Date, description: String) {
    self.value = value
    self.date = date
    self.description = description
  }
}
