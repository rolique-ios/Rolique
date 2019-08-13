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

public final class GetAllUsers: Route {
  public init() {
    super.init(endpoint:"users", method: .get, urlParams: [:])
  }
}

public final class GetTodayUsersForRecordType: Route {
  public init(recordType: String) {
    super.init(endpoint:"users/today", method: .get, urlParams: ["record_type": recordType])
  }
}
