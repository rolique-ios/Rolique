//
//  Userable.swift
//  PeopleWidget
//
//  Created by Bohdan Savych on 8/2/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation

public protocol Userable {
  var name: String { get }
  var thumnailURL: URL? { get }
}
