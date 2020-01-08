//
//  GetPayments.swift
//  Networking
//
//  Created by Bohdan Savych on 1/8/20.
//

import Foundation

public final class GetPayments: Route {
  public init(cashOwner: String, startDate: String, endDate: String) {
    super.init(endpoint:"expense/payments", method: .get, urlParams: ["role": cashOwner, "start_date": startDate, "end_date": endDate])
  }
}
