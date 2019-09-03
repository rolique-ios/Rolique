//
//  FileManager.swift
//  Utils
//
//  Created by Maksym Ivanyk on 9/3/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public extension FileManager {
  func safeRemove(atPath path: String) {
    try? self.removeItem(atPath: path)
  }
}
