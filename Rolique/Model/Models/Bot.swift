//
//  Bot.swift
//  Rolique
//
//  Created by Andrii on 9/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

// MARK: - Bot
public class Bot: Codable {
  let userID, teamName, teamID: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case teamName = "team_name"
    case teamID = "team_id"
  }
  
  public init(userID: String, teamName: String, teamID: String) {
    self.userID = userID
    self.teamName = teamName
    self.teamID = teamID
  }
}
