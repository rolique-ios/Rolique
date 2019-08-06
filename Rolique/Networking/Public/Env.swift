//
//  Env.swift
//  Networking
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Env

public struct Env {
  public static let apiToken = Env.getValueForKey("ApiToken") ?? "no_api_token"
  public static let apiUrl = Env.getValueForKey("ApiUrl") ?? "no_api_url"
  public static let slackCliendId = Env.getValueForKey("SlackClientId") ?? "no_slack_client_id"
  public static let slackClientSecret = Env.getValueForKey("SlackClientSecret") ?? "no_slack_client_secret"
  public static let slackRedirectUri = "https://" + (Env.getValueForKey("SlackRedirectUri") ?? "no_slack_redirect_uri")
  public static let slackToken = Env.getValueForKey("SlackToken") ?? "no_slack_token"
  
  static func getValueForKey(_ key: String) -> String? {
    guard let secret = Bundle(identifier: "io.rolique.Env")?.infoDictionary?["Secret"] as? [String: Any] else { return nil }
    guard let value = secret[key] as? String else { return nil }
    return value
  }
}
