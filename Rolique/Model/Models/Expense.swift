//
//  Expense.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/9/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

final class Expense: Codable {
  // wanted to name just type but it is already reseved
  enum Direction {
    case `in`, out
    
    init?(apiName: String) {
      switch apiName {
      case "OUT":
        self = .out
      case "IN":
        self = .in
        
      default:
        return nil
      }
    }
  }
  enum CodingKeys: String, CodingKey, CaseIterable {
    case category,
    description,
    dateString = "date",
    paymentMode,
    type,
    total,
    currencyCode
  }
  
  let category: String?
  let description: String?
  private(set) var total: Double
  let date: Date?
  let paymentMethodType: PaymentMethodType?
  let direction: Direction?
  let dateString: String?
  let paymentMode: String?
  let type: String?
  let currencyCode: String?
  private let formatter = DateFormatters.withCurrentTimeZoneFormatter()
    
    var detailedDescription: String { category == nil ? description ?? "No description" : "\(category!): \(description ?? "No description")"}
  
  init(category: String?, description: String?, total: Double, dateString: String?, paymentMode: String?, type: String?, currencyCode: String?) {
    self.category = category
    self.description = description
    self.total = total
    self.dateString = dateString
    self.paymentMode = paymentMode
    self.type = type
    self.currencyCode = currencyCode
    self.date = self.formatter.date(from: dateString.orEmpty)
    self.paymentMethodType = PaymentMethodType(apiName: paymentMode.orEmpty)
    self.direction = Direction(apiName: self.type.orEmpty)
    
    self.total = total * (self.direction == .in ? 1 : -1)
  }
  
  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let category = try container.decodeIfPresent(String.self, forKey: .category)
    let description = try container.decodeIfPresent(String.self, forKey: .description)
    let total = try container.decodeIfPresent(Double.self, forKey: .total)
    let dateString = try container.decodeIfPresent(String.self, forKey: .dateString)
    let paymentMode = try container.decodeIfPresent(String.self, forKey: .paymentMode)
    let type = try container.decodeIfPresent(String.self, forKey: .type)
    let currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
  
    self.init(category: category, description: description, total: total ?? 0, dateString: dateString, paymentMode: paymentMode, type: type, currencyCode: currencyCode)
  }
}
