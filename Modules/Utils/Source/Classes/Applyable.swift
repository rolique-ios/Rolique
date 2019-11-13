//
//  Applyable.swift
//  Dip
//
//  Created by Bohdan Savych on 11/12/19.
//

import UIKit

public protocol Applyable: class {}

public extension Applyable {
  func apply(_ f: (Self) -> Void) -> Self { f(self); return self }
}

extension NSObject: Applyable {}
