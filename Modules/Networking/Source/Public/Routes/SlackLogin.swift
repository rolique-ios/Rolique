//
//  SlackLogin.swift
//  Networking
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public final class SlackLogin: Route {
  public init() {
    super.init(endpoint:"", method: .get, urlParams: [
      "client_id": Env.slackCliendId,
      "scope": "identity.basic",
      "redirect_uri": Env.slackRedirectUri,
    ])
    
    self.customUrl = URL(string: "https://slack.com/oauth/authorize")
  }
}

public final class SlackToken: Route {
  public init(code: String) {
    super.init(endpoint:"", method: .get, urlParams: [
      "code": code,
      "client_id": Env.slackCliendId,
      "client_secret": Env.slackClientSecret,
      "redirect_uri": Env.slackRedirectUri,
    ])
    
    self.customUrl = URL(string: "https://slack.com/api/oauth.access")
  }
}
