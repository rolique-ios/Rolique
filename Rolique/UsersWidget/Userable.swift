//
//  Userable.swift
//  PeopleWidget
//
//  Created by Bohdan Savych on 8/2/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation

public protocol Userable: Hashable {
  var name: String { get }
  var thumbnailURL: URL? { get }
}

public final class AnyUserable: Userable {
  public var base: AnyHashable
  public var name: String
  public var thumbnailURL: URL?
  
  public init<T: Userable>(_ base: T) {
    self.base = AnyHashable(base)
    self.name = base.name
    self.thumbnailURL = base.thumbnailURL
  }
}

extension AnyUserable: Equatable {
  public static func == (lhs: AnyUserable, rhs: AnyUserable) -> Bool {
    return lhs.base == rhs.base
  }
}

extension AnyUserable: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.base.hashValue)
  }
}
