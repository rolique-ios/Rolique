//
//  GetUserWithId.swift
//  Networking
//
//  Created by Andrii on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public final class GetUserWithId: Route {
  public init(userId: String) {
    super.init(endpoint:"user", method: .get, urlParams: ["id": userId])
  }
}
