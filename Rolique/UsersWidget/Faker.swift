//
//  Faker.swift
//  PeopleWidget
//
//  Created by Bohdan Savych on 8/3/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation

final class Faker {
  struct User: Userable {
    let name: String
    let thumnailURL: URL?
  }
  
  static let shared = Faker()
  private init() {}
  
  func generateUsers() -> [Userable] {
    return [User(name: "Bohdan", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Max", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Vladimir", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Franchesko", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Yurii", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Yakiv", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Andrew", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "John", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Misha", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Artur", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50")),
            User(name: "Vlad", thumnailURL: URL(string: "https://picsum.photos/id/1035/50/50"))
    ]
  }
}
