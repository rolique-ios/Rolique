//
//  GetBalance.swift
//  Dip
//
//  Created by Bohdan Savych on 12/12/19.
//

import Foundation

public final class GetBalance: Route {
  public init(cashOwner: String) {
    super.init(endpoint:"expense/balance", method: .get, urlParams: ["role": cashOwner])
  }
}
